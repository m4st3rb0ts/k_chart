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
    this.datas,
    required this.scaleX,
    required this.scrollX,
    required this.isLongPress,
    required this.selectX,
    this.primaryIndicator = PrimaryIndicator.MA,
    this.volHidden = false,
    this.secondaryIndicator = SecondaryIndicator.MACD,
    this.isLine = false,
  }) {
    mItemCount = datas?.length ?? 0;
    mDataLen = mItemCount * chartStyle.pointWidth;
    initFormats();
  }

  static double maxScrollX = 0.0;
  List<KLineEntity>? datas;
  final ChartStyle chartStyle;

  PrimaryIndicator primaryIndicator;
  SecondaryIndicator secondaryIndicator;

  bool volHidden;
  double scaleX = 1.0;
  double scrollX = 0.0;
  double selectX;
  bool isLongPress = false;
  bool isLine;

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
  int mItemCount = 0;
  double mDataLen = 0.0; //数据占屏幕总长度

  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]; //格式化时间

  void initFormats() {
    if (chartStyle.dateTimeFormat != null) {
      mFormats = chartStyle.dateTimeFormat!;
      return;
    }

    if (mItemCount < 2) {
      mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
      return;
    }

    int firstTime = datas!.first.time ?? 0;
    int secondTime = datas![1].time ?? 0;
    int time = secondTime - firstTime;
    time ~/= 1000;
    //月线
    if (time >= 24 * 60 * 60 * 28)
      mFormats = [yy, '-', mm];
    //日线等
    else if (time >= 24 * 60 * 60)
      mFormats = [yy, '-', mm, '-', dd];
    //小时线等
    else
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
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
    if (datas != null && datas!.isNotEmpty) {
      drawChart(canvas: canvas, size: size);
      drawRightText(canvas: canvas);
      drawDate(canvas: canvas, size: size);

      drawText(canvas: canvas, data: datas!.last, x: 5);
      drawMaxAndMin(canvas: canvas);
      drawNowPrice(canvas: canvas);

      if (isLongPress == true) {
        drawCrossLine(canvas: canvas, size: size);
        drawCrossLineText(canvas: canvas, size: size);
      }
    }
    canvas.restore();
  }

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

  void initRect({required final Size size}) {
    double volHeight = volHidden != true ? mDisplayHeight * 0.2 : 0;
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

    if (volHidden != true) {
      mVolRect = Rect.fromLTRB(
        0,
        mMainRect.bottom + chartStyle.childPadding,
        mWidth,
        mMainRect.bottom + volHeight,
      );
    }

    //secondaryState == SecondaryState.NONE隐藏副视图
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
    if (datas == null) return;
    if (datas!.isEmpty) return;
    maxScrollX = getMinTranslateX().abs();
    setTranslateXFromScrollX(scrollX: scrollX);
    mStartIndex = indexOfTranslateX(translateX: xToTranslateX(x: 0));
    mStopIndex = indexOfTranslateX(translateX: xToTranslateX(x: mWidth));
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      var item = datas![i];
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

    if (isLine == true) {
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

  double xToTranslateX({required final double x}) => -mTranslateX + x / scaleX;

  int indexOfTranslateX({required final double translateX}) =>
      _indexOfTranslateX(translateX: translateX, start: 0, end: mItemCount - 1);

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

  KLineEntity getItem({required final int position}) {
    return datas![position];
    // if (datas != null) {
    //   return datas[position];
    // } else {
    //   return null;
    // }
  }

  ///scrollX 转换为 TranslateX
  void setTranslateXFromScrollX({required final double scrollX}) =>
      mTranslateX = scrollX + getMinTranslateX();

  ///获取平移的最小值
  double getMinTranslateX() {
    var x = -mDataLen + mWidth / scaleX - chartStyle.pointWidth * 0.5;
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
      (translateX + mTranslateX) * scaleX;

  TextStyle getTextStyle({required final Color color}) {
    return TextStyle(fontSize: 10.0, color: color);
  }

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
//    return oldDelegate.datas != datas ||
//        oldDelegate.datas?.length != datas?.length ||
//        oldDelegate.scaleX != scaleX ||
//        oldDelegate.scrollX != scrollX ||
//        oldDelegate.isLongPress != isLongPress ||
//        oldDelegate.selectX != selectX ||
//        oldDelegate.isLine != isLine ||
//        oldDelegate.mainState != mainState ||
//        oldDelegate.secondaryState != secondaryState;
  }
}
