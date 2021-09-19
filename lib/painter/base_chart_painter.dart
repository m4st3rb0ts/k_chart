import 'dart:math';

import 'package:flutter/material.dart'
    show Color, TextStyle, Rect, Canvas, Size, CustomPainter;
import 'package:k_chart/utils/date_format_util.dart';

import '../chart_style.dart' show ChartStyle;
import '../entity/k_line_entity.dart';
import '../k_chart_widget.dart';

export 'package:flutter/material.dart'
    show Color, required, TextStyle, Rect, Canvas, Size, CustomPainter;

abstract class BaseChartPainter extends CustomPainter {
  BaseChartPainter({
    required this.chartStyle,
    required this.dataSource,
    this.primaryIndicator = PrimaryIndicator.MA,
    this.secondaryIndicator = SecondaryIndicator.MACD,
    this.hideVolumeChart = false,
    this.displayTimeLineChart = false,
    this.horizontalScale = 1.0,
    this.currentHorizontalScroll = 0.0,
    this.isLongPress = false,
    required this.selectX,
  }) {
    _initDateFormats();
  }

  final List<KLineEntity> dataSource;
  final ChartStyle chartStyle;
  final PrimaryIndicator primaryIndicator;
  final SecondaryIndicator secondaryIndicator;
  final bool hideVolumeChart;
  final bool displayTimeLineChart;
  List<String> displayDateFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
  final double horizontalScale;
  final double currentHorizontalScroll;
  final bool isLongPress;

  //TOREVIEW GOING DOWN
  static double maxScrollX = 0.0;
  double selectX;

  //3块区域大小与位置
  late Rect mMainRect;
  Rect? mVolRect;
  Rect? mSecondaryRect;

  late double mDisplayHeight;
  late double mWidth;
  int mStartIndex = 0;
  int mStopIndex = 0;
  double mMainMaxValue = double.minPositive;
  double mMainMinValue = double.maxFinite;
  double mVolMaxValue = double.minPositive;
  double mVolMinValue = double.maxFinite;
  double mSecondaryMaxValue = double.minPositive;
  double mSecondaryMinValue = double.maxFinite;
  double mTranslateX = double.minPositive;
  int mMainMaxIndex = 0;
  int mMainMinIndex = 0;
  double mMainHighMaxValue = double.minPositive;
  double mMainLowMinValue = double.maxFinite;

  // Init data format
  void _initDateFormats() {
    if (chartStyle.dateTimeFormat != null) {
      displayDateFormats = chartStyle.dateTimeFormat!;
      return;
    }

    if (dataSource.length < 2) {
      displayDateFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
      return;
    }

    final firstTime = dataSource.first.time ?? 0;
    final secondTime = dataSource[1].time ?? 0;
    final time = (secondTime - firstTime) ~/ 1000;

    if (time >= 24 * 60 * 60 * 28) {
      //Monthly line
      displayDateFormats = [yy, '-', mm];
    } else if (time >= 24 * 60 * 60) {
      //Daily line
      displayDateFormats = [yy, '-', mm, '-', dd];
    } else {
      //Hourly line
      displayDateFormats = [mm, '-', dd, ' ', HH, ':', nn];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    mDisplayHeight =
        size.height - chartStyle.topPadding - chartStyle.bottomPadding;
    mWidth = size.width;
    initRect(size: size);
    calculateValue();
    initChartRenderer();

    canvas.save();
    canvas.scale(1, 1);
    drawBackground(canvas: canvas, size: size);
    drawGrid(canvas: canvas);
    if (dataSource.isNotEmpty) {
      drawChart(canvas: canvas, size: size);
      drawRightText(canvas: canvas);
      drawDate(canvas: canvas, size: size);

      drawText(canvas: canvas, data: dataSource.last, x: 5);
      drawMaxAndMin(canvas: canvas);
      drawNowPrice(canvas: canvas);

      if (isLongPress) {
        drawCrossLine(canvas: canvas, size: size);
        drawCrossLineText(canvas: canvas, size: size);
      }
    }
    canvas.restore();
  }

  void initRect({required final Size size}) {
    double volHeight = hideVolumeChart != true ? mDisplayHeight * 0.2 : 0;
    double secondaryHeight = secondaryIndicator != SecondaryIndicator.NONE
        ? mDisplayHeight * 0.2
        : 0;

    double mainHeight = mDisplayHeight;
    mainHeight -= volHeight;
    mainHeight -= secondaryHeight;

    mMainRect = Rect.fromLTRB(
      0,
      chartStyle.topPadding,
      mWidth,
      chartStyle.topPadding + mainHeight,
    );

    if (hideVolumeChart != true) {
      mVolRect = Rect.fromLTRB(
        0,
        mMainRect.bottom + chartStyle.childPadding,
        mWidth,
        mMainRect.bottom + volHeight,
      );
    }

    if (secondaryIndicator != SecondaryIndicator.NONE) {
      mSecondaryRect = Rect.fromLTRB(
        0,
        mMainRect.bottom + volHeight + chartStyle.childPadding,
        mWidth,
        mMainRect.bottom + volHeight + secondaryHeight,
      );
    }
  }

  void calculateValue() {
    if (dataSource.isEmpty) {
      return;
    }
    maxScrollX = getMinTranslateX().abs();
    setTranslateXFromScrollX(scrollX: currentHorizontalScroll);
    mStartIndex = indexOfTranslateX(translateX: xToTranslateX(x: 0));
    mStopIndex = indexOfTranslateX(translateX: xToTranslateX(x: mWidth));
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      var item = dataSource[i];
      getMainMaxMinValue(item: item, i: i);
      getVolMaxMinValue(item: item);
      getSecondaryMaxMinValue(item: item);
    }
  }

  void getMainMaxMinValue(
      {required final KLineEntity item, required final int i}) {
    double maxPrice, minPrice;
    if (primaryIndicator == PrimaryIndicator.MA) {
      maxPrice = max(item.high, _findMaxMA(a: item.maValueList ?? [0]));
      minPrice = min(item.low, _findMinMA(a: item.maValueList ?? [0]));
    } else if (primaryIndicator == PrimaryIndicator.BOLL) {
      maxPrice = max(item.up ?? 0, item.high);
      minPrice = min(item.dn ?? 0, item.low);
    } else {
      maxPrice = item.high;
      minPrice = item.low;
    }
    mMainMaxValue = max(mMainMaxValue, maxPrice);
    mMainMinValue = min(mMainMinValue, minPrice);

    if (mMainHighMaxValue < item.high) {
      mMainHighMaxValue = item.high;
      mMainMaxIndex = i;
    }
    if (mMainLowMinValue > item.low) {
      mMainLowMinValue = item.low;
      mMainMinIndex = i;
    }

    if (displayTimeLineChart == true) {
      mMainMaxValue = max(mMainMaxValue, item.close);
      mMainMinValue = min(mMainMinValue, item.close);
    }
  }

  double _findMaxMA({required final List<double> a}) {
    double result = double.minPositive;
    for (double i in a) {
      result = max(result, i);
    }
    return result;
  }

  double _findMinMA({required final List<double> a}) {
    double result = double.maxFinite;
    for (double i in a) {
      result = min(result, i == 0 ? double.maxFinite : i);
    }
    return result;
  }

  void getVolMaxMinValue({required final KLineEntity item}) {
    mVolMaxValue = max(mVolMaxValue,
        max(item.vol, max(item.MA5Volume ?? 0, item.MA10Volume ?? 0)));
    mVolMinValue = min(mVolMinValue,
        min(item.vol, min(item.MA5Volume ?? 0, item.MA10Volume ?? 0)));
  }

  void getSecondaryMaxMinValue({required final KLineEntity item}) {
    if (secondaryIndicator == SecondaryIndicator.MACD) {
      if (item.macd != null) {
        mSecondaryMaxValue =
            max(mSecondaryMaxValue, max(item.macd!, max(item.dif!, item.dea!)));
        mSecondaryMinValue =
            min(mSecondaryMinValue, min(item.macd!, min(item.dif!, item.dea!)));
      }
    } else if (secondaryIndicator == SecondaryIndicator.KDJ) {
      if (item.d != null) {
        mSecondaryMaxValue =
            max(mSecondaryMaxValue, max(item.k!, max(item.d!, item.j!)));
        mSecondaryMinValue =
            min(mSecondaryMinValue, min(item.k!, min(item.d!, item.j!)));
      }
    } else if (secondaryIndicator == SecondaryIndicator.RSI) {
      if (item.rsi != null) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, item.rsi!);
        mSecondaryMinValue = min(mSecondaryMinValue, item.rsi!);
      }
    } else if (secondaryIndicator == SecondaryIndicator.WR) {
      mSecondaryMaxValue = 0;
      mSecondaryMinValue = -100;
    } else if (secondaryIndicator == SecondaryIndicator.CCI) {
      if (item.cci != null) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, item.cci!);
        mSecondaryMinValue = min(mSecondaryMinValue, item.cci!);
      }
    } else {
      mSecondaryMaxValue = 0;
      mSecondaryMinValue = 0;
    }
  }

  double xToTranslateX({required final double x}) =>
      -mTranslateX + x / horizontalScale;

  int indexOfTranslateX({required final double translateX}) =>
      _indexOfTranslateX(
          translateX: translateX, start: 0, end: dataSource.length - 1);

  ///二分查找当前值的index
  int _indexOfTranslateX(
      {required final double translateX,
      required final int start,
      required final int end}) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(position: start);
      double endValue = getX(position: end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(position: mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX: translateX, start: start, end: mid);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX: translateX, start: mid, end: end);
    } else {
      return mid;
    }
  }

  ///根据索引索取x坐标
  ///+ mPointWidth / 2防止第一根和最后一根k线显示不���
  ///@param position 索引值
  double getX({required final int position}) =>
      position * chartStyle.pointWidth + chartStyle.pointWidth * 0.5;

  KLineEntity? getItem({required final int position}) {
    if (position >= 0 && position < dataSource.length) {
      return dataSource[position];
    } else {
      return null;
    }
  }

  ///scrollX 转换为 TranslateX
  void setTranslateXFromScrollX({required final double scrollX}) =>
      mTranslateX = scrollX + getMinTranslateX();

  ///获取平移的最小值
  double getMinTranslateX() {
    var x = -dataSource.length * chartStyle.pointWidth +
        mWidth / horizontalScale -
        chartStyle.pointWidth * 0.5;
    return x >= 0 ? 0.0 : x;
  }

  ///计算长按后x的值，转换为index
  int calculateSelectedX({required final double selectX}) {
    int mSelectedIndex =
        indexOfTranslateX(translateX: xToTranslateX(x: selectX));
    if (mSelectedIndex < mStartIndex) {
      mSelectedIndex = mStartIndex;
    }
    if (mSelectedIndex > mStopIndex) {
      mSelectedIndex = mStopIndex;
    }
    return mSelectedIndex;
  }

  ///translateX转化为view中的x
  double translateXtoX({required final double translateX}) =>
      (translateX + mTranslateX) * horizontalScale;

  TextStyle getTextStyle({required final Color color}) =>
      TextStyle(fontSize: 10.0, color: color);

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) => true;

  void initChartRenderer();

  void drawBackground({
    required final Canvas canvas,
    required final Size size,
  });

  void drawGrid({
    required final Canvas canvas,
  });

  void drawChart({
    required final Canvas canvas,
    required final Size size,
  });

  void drawRightText({
    required final Canvas canvas,
  });

  void drawDate({
    required final Canvas canvas,
    required final Size size,
  });

  void drawText({
    required final Canvas canvas,
    required final KLineEntity data,
    required final double x,
  });

  void drawMaxAndMin({
    required final Canvas canvas,
  });

  void drawNowPrice({
    required final Canvas canvas,
  });

  void drawCrossLine({
    required final Canvas canvas,
    required final Size size,
  });

  void drawCrossLineText({
    required final Canvas canvas,
    required final Size size,
  });
}
