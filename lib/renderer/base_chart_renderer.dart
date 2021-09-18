import 'package:flutter/material.dart';

export '../chart_style.dart';

/// Base class for adding chart renders
abstract class BaseChartRenderer<T> {
  BaseChartRenderer({
    required this.chartRect,
    required this.maxYValue,
    required this.minYValue,
    required this.topPadding,
    required this.fixedDecimalsLength,
    required Color gridColor,
  }) {
    if (maxYValue == minYValue) {
      maxYValue *= 1.5;
      minYValue /= 2;
    }
    scaleY = chartRect.height / (maxYValue - minYValue);
    gridPaint.color = gridColor;
    // print("maxValue=====" + maxValue.toString() + "====minValue===" + minValue.toString() + "==scaleY==" + scaleY.toString());
  }

  /// Max y value of the chart
  double maxYValue;

  /// Min y value of the chart
  double minYValue;

  /// Factor for scaling the graph (zoom)
  late double scaleY;

  /// Margin of the maxYValue of the graph with the top
  final double topPadding;

  /// Full chart rect size where all content will be drawed
  final Rect chartRect;

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
      (maxYValue - value) * scaleY + chartRect.top;

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
    required int gridRows,
    required int gridColumns,
  });

  /// Draws a text at the top of the chart
  /// @canvas surface to paint
  /// @data the text to paint
  /// @x the left offset where the text will be painted
  void drawText({
    required final Canvas canvas,
    required T data,
    required double x,
  });

  /// Draws a text on the right of the chart
  /// @canvas surface to paint
  /// @textStyle
  /// @gridRows the number of the row which the text will be painted
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required int gridRows,
  });

  /// Draws the chart
  /// @lastPoint
  /// @curPoint
  /// @lastX
  /// @curX
  /// @size
  /// @canvas surface to paint
  void drawChart({
    required final T lastPoint,
    required T curPoint,
    required double lastX,
    required double curX,
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
    final double? lastPrice,
    final double? curPrice,
    required final Canvas canvas,
    required final double lastX,
    required final double curX,
    required final Color color,
  }) {
    if (lastPrice == null || curPrice == null) {
      return;
    }
    //("lasePrice==" + lastPrice.toString() + "==curPrice==" + curPrice.toString());
    double lastY = getVerticalPositionForPoint(value: lastPrice);
    double curY = getVerticalPositionForPoint(value: curPrice);
    //print("lastX-----==" + lastX.toString() + "==lastY==" + lastY.toString() + "==curX==" + curX.toString() + "==curY==" + curY.toString());
    canvas.drawLine(
        Offset(lastX, lastY), Offset(curX, curY), chartPaint..color = color);
  }

  /// Get the basic textstyle for painting in the chart renreder
  /// @color The color of the text
  TextStyle getTextStyle({required final Color color}) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}
