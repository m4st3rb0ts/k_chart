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
    this.shouldDisplaySelection = false,
    required this.selectedHorizontalValue,
  }) {
    _initDateFormats();
  }

  /// Data to display in the graph
  final List<KLineEntity> dataSource;

  /// Graph data
  final ChartStyle chartStyle;

  /// First indicator to display in candles
  final PrimaryIndicator primaryIndicator;

  /// Second indicator to display in another graph
  final SecondaryIndicator secondaryIndicator;

  /// Should display volume?
  final bool hideVolumeChart;

  /// Should display line chart instead candles?
  final bool displayTimeLineChart;

  /// Time format for display dates
  List<String> displayDateFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];

  /// current scale
  final double horizontalScale;

  // current position in the graph
  final double currentHorizontalScroll;

  // If want to display data from a selected point
  final bool shouldDisplaySelection;

  // selected horizontal value in this case the dates
  final double selectedHorizontalValue;

  double maxHorizontalScrollWidth({required final Size size}) {
    final dataWidth = -dataSource.length * chartStyle.pointWidth +
        size.width / horizontalScale -
        chartStyle.pointWidth * 0.5;
    return dataWidth >= 0 ? 0.0 : dataWidth.abs();
  }

  // TODO: Review
  /// Last size of the latest painted canvas
  Size get lastPaintedSize => _lastPaintedSize;
  Size _lastPaintedSize = Size.zero;

  //TOREVIEW GOING DOWN
  int mStartIndex = 0;
  int mStopIndex = 0;
  double mMainMaxValue = double.minPositive;
  double mMainMinValue = double.maxFinite;
  double mVolMaxValue = double.minPositive;
  double mVolMinValue = double.maxFinite;
  double mSecondaryMaxValue = double.minPositive;
  double mSecondaryMinValue = double.maxFinite;
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

  double getCurrentOffset({required final Size size}) {
    return currentHorizontalScroll - maxHorizontalScrollWidth(size: size);
  }

  // [] Reviewed
  @override
  void paint(Canvas canvas, Size size) {
    _lastPaintedSize = size;
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    calculateValue(size: size);
    initChartRenderer(size: size);

    canvas.save();
    canvas.scale(1, 1);
    drawBackground(canvas: canvas, size: size);
    drawGrid(canvas: canvas, size: size);
    if (dataSource.isNotEmpty) {
      drawChart(canvas: canvas, size: size);
      drawRightText(canvas: canvas, size: size);
      drawDate(canvas: canvas, size: size);

      drawText(canvas: canvas, data: dataSource.last, x: 5, size: size);
      drawMaxAndMin(canvas: canvas, size: size);
      drawNowPrice(canvas: canvas, size: size);

      if (shouldDisplaySelection) {
        drawCrossLine(canvas: canvas, size: size);
        drawCrossLineText(canvas: canvas, size: size);
      }
    }
    canvas.restore();
  }

  // [] Reviewed
  void calculateValue({required final Size size}) {
    if (dataSource.isEmpty) {
      return;
    }

    mStartIndex = dataIndexInViewportFor(
        leftOffset: translateToCurrentViewport(leftOffset: 0, size: size));
    mStopIndex = dataIndexInViewportFor(
        leftOffset:
            translateToCurrentViewport(leftOffset: size.width, size: size));
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
      maxPrice = max(item.top ?? 0, item.high);
      minPrice = min(item.bottom ?? 0, item.low);
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

  // [] Reviewed
  double _findMaxMA({required final List<double> a}) {
    double result = double.minPositive;
    for (double i in a) {
      result = max(result, i);
    }
    return result;
  }

  // [] Reviewed
  double _findMinMA({required final List<double> a}) {
    double result = double.maxFinite;
    for (double i in a) {
      result = min(result, i == 0 ? double.maxFinite : i);
    }
    return result;
  }

  // [] Reviewed
  void getVolMaxMinValue({required final KLineEntity item}) {
    mVolMaxValue = max(mVolMaxValue,
        max(item.vol, max(item.MA5Volume ?? 0, item.MA10Volume ?? 0)));
    mVolMinValue = min(mVolMinValue,
        min(item.vol, min(item.MA5Volume ?? 0, item.MA10Volume ?? 0)));
  }

  // [] Reviewed
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

  /// Translate a leftOffset position to the current viewport
  double translateToCurrentViewport(
          {required final double leftOffset, required final Size size}) =>
      -getCurrentOffset(size: size) + leftOffset / horizontalScale;

  /// Binary search of the current data index for the current viewport for a giving leftOffset
  int dataIndexInViewportFor({required final double leftOffset}) {
    final start = 0;
    final end = dataSource.length - 1;

    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      final startValue = getLeftOffsetByIndex(index: start);
      final endValue = getLeftOffsetByIndex(index: end);
      return (leftOffset - startValue).abs() < (leftOffset - endValue).abs()
          ? start
          : end;
    }

    var _end = end;
    int mid = 0;
    for (var _start = start; _start < _end; _start++) {
      mid = (_start + (_end - _start) * 0.5).floor();
      final midValue = getLeftOffsetByIndex(index: mid);
      if (leftOffset < midValue) {
        _end = mid;
      } else if (leftOffset > midValue) {
        _start = mid;
      } else {
        break;
      }
    }
    return mid;
  }

  /// Get the left offset for a giving index
  /// @param index
  double getLeftOffsetByIndex({required final int index}) =>
      //*0.5 Prevent the first and last bars from displaying incorrectly
      index * chartStyle.pointWidth + chartStyle.pointWidth * 0.5;

  /// Get the data item by an index
  /// @param index
  KLineEntity? getDataItemByIndex({required final int index}) {
    if (index >= 0 && index < dataSource.length) {
      return dataSource[index];
    } else {
      return null;
    }
  }

  /// Gets the index of the current selected horizontal value
  int getIndexForSelectedHorizontalValue({required final Size size}) {
    final selectedIndex = dataIndexInViewportFor(
      leftOffset: translateToCurrentViewport(
        leftOffset: selectedHorizontalValue,
        size: size,
      ),
    );
    if (selectedIndex < mStartIndex) {
      return mStartIndex;
    } else if (selectedIndex > mStopIndex) {
      return mStopIndex;
    } else {
      return selectedIndex;
    }
  }

  // [] Reviewed
  ///translateX转化为view中的x
  double translateXtoX(
          {required final double translateX, required final Size size}) =>
      (translateX + getCurrentOffset(size: size)) * horizontalScale;

  // [] Reviewed
  // Duplicated in base chart rendered
  TextStyle getTextStyle({required final Color color}) =>
      TextStyle(fontSize: 10.0, color: color);

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) => true;

  // Implement in child classes
  void initChartRenderer({required final Size size});

  void drawBackground({
    required final Canvas canvas,
    required final Size size,
  });

  void drawGrid({
    required final Canvas canvas,
    required final Size size,
  });

  void drawChart({
    required final Canvas canvas,
    required final Size size,
  });

  void drawRightText({
    required final Canvas canvas,
    required final Size size,
  });

  void drawDate({
    required final Canvas canvas,
    required final Size size,
  });

  void drawText({
    required final Canvas canvas,
    required final Size size,
    required final KLineEntity data,
    required final double x,
  });

  void drawMaxAndMin({
    required final Canvas canvas,
    required final Size size,
  });

  void drawNowPrice({
    required final Canvas canvas,
    required final Size size,
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
