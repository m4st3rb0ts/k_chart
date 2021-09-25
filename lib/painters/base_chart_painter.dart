//
// Created by @OpenFlutter & @sh1l0n
//

import 'package:flutter/material.dart'
    show Color, TextStyle, Rect, Canvas, Size, CustomPainter;
import 'package:intl/intl.dart';

import '../chart_style.dart' show ChartStyle;
import '../entity/k_line_entity.dart';

export 'package:flutter/material.dart'
    show Color, required, TextStyle, Rect, Canvas, Size, CustomPainter;

abstract class BaseChartPainter extends CustomPainter {
  BaseChartPainter({
    required this.chartStyle,
    required this.dataSource,
    required this.displayDateFormat,
    this.horizontalScale = 1.0,
    this.currentHorizontalScroll = 0.0,
    this.shouldDisplaySelection = false,
    required this.selectedHorizontalValue,
  });

  /// Data to display in the graph
  final List<KLineEntity> dataSource;

  /// Graph data
  final ChartStyle chartStyle;

  /// Time format for display dates
  final DateFormat displayDateFormat;

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

      drawText(
          canvas: canvas,
          data: dataSource[
              dataIndexInViewportFor(leftOffset: currentHorizontalScroll)],
          x: 5,
          size: size);
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
  }

  /// Translate a leftOffset position to the current viewport
  double translateToCurrentViewport(
          {required final double leftOffset, required final Size size}) =>
      -getCurrentOffset(size: size) + leftOffset / horizontalScale;

  /// Binary search of the current data index for the current viewport for a giving leftOffset
  int dataIndexInViewportFor({required final double leftOffset}) {
    var start = 0;
    var end = dataSource.length - 1;

    int mid = start;
    while (start != end) {
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

      mid = (start + (end - start) * 0.5).floor();
      final midValue = getLeftOffsetByIndex(index: mid);
      if (leftOffset < midValue) {
        end = mid;
      } else if (leftOffset > midValue) {
        start = mid;
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

  String getDate(final int? date) => displayDateFormat.format(
        DateTime.fromMillisecondsSinceEpoch(
          date ?? DateTime.now().millisecondsSinceEpoch,
        ),
      );

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
