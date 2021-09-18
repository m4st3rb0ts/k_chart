import 'package:flutter/material.dart';
import 'package:k_chart/chart_style.dart';

export '../chart_style.dart';

/// Base class for adding chart renders
abstract class BaseChartRenderer<T> {
  BaseChartRenderer({
    required this.displayRect,
    required this.maxVerticalValue,
    required this.minVerticalValue,
    required this.contentTopPadding,
    required this.fixedDecimalsLength,
    required this.chartStyle,
  })  : chartPaint = Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high
          ..strokeWidth = 1.0
          ..color = Colors.red,
        gridPaint = Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high
          ..strokeWidth = 0.5
          ..color = chartStyle.colors.gridColor {
    if (maxVerticalValue == minVerticalValue) {
      maxVerticalValue *= 1.5;
      minVerticalValue /= 2;
    }
    verticalScale = displayRect.height / (maxVerticalValue - minVerticalValue);
  }

  /// Max y value of the chart
  late double maxVerticalValue;

  /// Min y value of the chart
  late double minVerticalValue;

  /// Factor for scaling the graph (zoom)
  late double verticalScale;

  /// Margin of the maxYValue of the graph with the top
  final double contentTopPadding;

  /// Full chart rect size where all content will be drawed
  final Rect displayRect;

  /// Fixed number of decimals
  final int fixedDecimalsLength;

  /// Custom paint for the chart
  final Paint chartPaint;

  /// Custom paint for the grid
  final Paint gridPaint;

  /// Defined style of chart
  final ChartStyle chartStyle;

  /// Gets the vertical position in the chart given a y value
  /// @value the value for computing the y position
  double getVerticalPositionForPoint({required final double value}) =>
      (maxVerticalValue - value) * verticalScale + displayRect.top;

  /// Format a number to a fixed number of decimals
  /// @n the number to format
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
  /// @textStyle style for displaying the text
  /// @gridRows the number of the row which the text will be painted
  void drawRightText({
    required final Canvas canvas,
    required final TextStyle textStyle,
  });

  /// Draws the chart
  /// @lastValue last value in data
  /// @currentValue current value in data
  /// @canvas surface to paint
  void drawChart({
    required final RenderData<T> lastValue,
    required final RenderData<T> currentValue,
    required Size size,
    required Canvas canvas,
  });

  /// Draws a line
  /// @lastValue from
  /// @currentValue to
  /// @canvas surface to paint
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
      chartPaint..color = color,
    );
  }

  /// Get the basic textstyle for painting in the chart renreder
  /// @color The color of the text
  TextStyle getTextStyle({required final Color color}) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}

/// class for drawing points in current render
class RenderPoint {
  const RenderPoint({required this.x, this.y});
  final double x;
  final double? y;
}

/// class for drawing data in current render
class RenderData<T> {
  const RenderData({required this.data, required this.x});
  final T data;
  final double x;
}
