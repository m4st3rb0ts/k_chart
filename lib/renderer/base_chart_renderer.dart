import 'package:flutter/material.dart';

export '../chart_style.dart';

/// Base class for adding chart renders
abstract class BaseChartRenderer<T> {
  BaseChartRenderer({
    required this.displayRect,
    required this.maxVerticalValue,
    required this.minVerticalValue,
    required this.contentTopPadding,
    required this.fixedDecimalsLength,
    required Color gridColor,
  }) {
    if (maxVerticalValue == minVerticalValue) {
      maxVerticalValue *= 1.5;
      minVerticalValue /= 2;
    }
    verticalScale = displayRect.height / (maxVerticalValue - minVerticalValue);
    gridPaint.color = gridColor;
    // print("maxValue=====" + maxValue.toString() + "====minValue===" + minValue.toString() + "==scaleY==" + scaleY.toString());
  }

  /// Max y value of the chart
  double maxVerticalValue;

  /// Min y value of the chart
  double minVerticalValue;

  /// Factor for scaling the graph (zoom)
  late double verticalScale;

  /// Margin of the maxYValue of the graph with the top
  final double contentTopPadding;

  /// Full chart rect size where all content will be drawed
  final Rect displayRect;

  /// Fixed number of decimals
  final int fixedDecimalsLength;

  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;

  final Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5
    ..color = Color(0xff4c5c74);

  /// Gets the vertical position in the chart given a y value
  /// @value the value for computing the y position
  double getVerticalPositionForPoint({required final double value}) =>
      (maxVerticalValue - value) * verticalScale + displayRect.top;

  String format({final double? n}) {
    if (n == null || n.isNaN) {
      return "0.00";
    } else {
      return n.toStringAsFixed(fixedDecimalsLength);
    }
  }

  /// Draws the chart grid
  /// @canvas surface to paint
  /// @gridRows number of rows
  /// @gridColumns number of columns
  void drawGrid({
    required final Canvas canvas,
    required int numberOfRows,
    required int numberOfColumns,
  });

  /// Draws a text at the top of the chart
  /// @canvas surface to paint
  /// @data the text to paint
  /// @x the left offset where the text will be painted
  void drawText({
    required final Canvas canvas,
    required T value,
    required double leftOffset,
  });

  /// Draws a text on the right of the chart
  /// @canvas surface to paint
  /// @textStyle
  /// @gridRows the number of the row which the text will be painted
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required int numberOfRows,
  });

  /// Draws the chart
  /// @lastPoint
  /// @curPoint
  /// @lastX
  /// @curX
  /// @size
  /// @canvas surface to paint
  void drawChart({
    required final RenderData<T> lastValue,
    required final RenderData<T> currentValue,
    required Size size,
    required Canvas canvas,
  });

  /// Draws a line
  /// @lastPrice
  /// @curPrice
  /// @canvas surface to paint
  /// @lastX
  /// @curX
  /// @color The color of the line
  void drawLine({
    required final RenderPoint lastValue,
    required final RenderPoint currentValue,
    required final Canvas canvas,
    required final Color color,
  }) {
    if (lastValue.y == null || currentValue.y == null) {
      return;
    }
    canvas.drawLine(
        Offset(
          lastValue.x,
          getVerticalPositionForPoint(value: lastValue.y ?? 0),
        ),
        Offset(
          currentValue.x,
          getVerticalPositionForPoint(value: currentValue.y ?? 0),
        ),
        chartPaint..color = color);
  }

  /// Get the basic textstyle for painting in the chart renreder
  /// @color The color of the text
  TextStyle getTextStyle({required final Color color}) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}

class RenderPoint {
  const RenderPoint({required this.x, this.y});
  final double x;
  final double? y;
}

class RenderData<T> {
  const RenderData({required this.data, required this.x});
  final T data;
  final double x;
}
