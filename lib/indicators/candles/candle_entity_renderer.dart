//
// Created by @OpenFlutter & @sh1l0n
//

import 'package:flutter/material.dart';
import 'package:k_chart/indicators/candles/candle.dart';

import '../../chart_style.dart';
import '../../renders/base_chart_renderer.dart';
import 'candles_indicator.dart';

/// Candle data render
class CandleEntityRender extends BaseChartRenderer<Candle> {
  CandleEntityRender({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required this.indicator,
    required this.isTimeLineMode,
    required final int fixedDecimalsLength,
    required final ChartStyle chartStyle,
    required this.timelineHorizontalScale,
    this.maFactorsForTitles = const [5, 10, 20],
  }) : super(
          displayRect: displayRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          fixedDecimalsLength: fixedDecimalsLength,
          chartStyle: chartStyle,
        ) {
    _timelinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = chartStyle.colors.kLineColor;
    _contentRect = Rect.fromLTRB(
      displayRect.left,
      displayRect.top + contentPadding,
      displayRect.right,
      displayRect.bottom - contentPadding,
    );
    verticalScale = _contentRect.height / (maxVerticalValue - minVerticalValue);
  }

  /// Indicator which together the candle graph should display (MA, BOLL, NONE)
  final CandlesIndicators indicator;

  /// Display timeline or candle mode
  final bool isTimeLineMode;

  /// Padding for content
  final double contentPadding = 5.0;

  // Suffix for MA titles computing
  final List<int> maFactorsForTitles;

  // Horizontal scale to use with timeline mode
  final double timelineHorizontalScale;

  /// Draw content area
  late Rect _contentRect;

  /// Paint to use for time isLine mode
  late Paint _timelinePaint;

  @override
  void drawText({
    required final Canvas canvas,
    required final Candle value,
    required final double leftOffset,
  }) {
    if (isTimeLineMode == true) {
      return;
    }
    TextSpan? titles;
    if (indicator == CandlesIndicators.MA) {
      titles = TextSpan(
        children: _createMATextSpan(data: value),
      );
    } else if (indicator == CandlesIndicators.BOLL) {
      titles = TextSpan(
        children: [
          if (value.top != 0)
            TextSpan(
              // TODO: Localize
              text: 'BOLL:${format(n: value.middle)}    ',
              style: getTextStyle(
                color: chartStyle.colors.ma5Color,
              ),
            ),
          if (value.middle != 0)
            TextSpan(
              // TODO: Localize
              text: 'UB:${format(n: value.top)}    ',
              style: getTextStyle(
                color: chartStyle.colors.ma10Color,
              ),
            ),
          if (value.bottom != 0)
            TextSpan(
              // TODO: Localize
              text: 'LB:${format(n: value.bottom)}    ',
              style: getTextStyle(
                color: chartStyle.colors.ma30Color,
              ),
            ),
        ],
      );
    }
    if (titles == null) {
      return;
    }
    final titlesPainter = TextPainter(
      text: titles,
      textDirection: TextDirection.ltr,
    );
    titlesPainter.layout();
    titlesPainter.paint(
      canvas,
      Offset(
        leftOffset,
        displayRect.top - chartStyle.topPadding,
      ),
    );
  }

  List<InlineSpan> _createMATextSpan({required final Candle data}) {
    var titles = <InlineSpan>[];
    for (var i = 0; i < data.maValueList.length; i++) {
      if (data.maValueList[i] != 0) {
        final title = TextSpan(
          //Localize
          text:
              'MA${maFactorsForTitles[i]}:${format(n: data.maValueList[i])}    ',
          style: getTextStyle(
            color: chartStyle.colors.getMAColor(i),
          ),
        );
        titles.add(title);
      }
    }
    return titles;
  }

  @override
  void drawChart({
    required final Canvas canvas,
    required final RenderData<Candle> lastValue,
    required final RenderData<Candle> currentValue,
    required final Size size,
  }) {
    if (!isTimeLineMode) {
      drawCandle(candle: currentValue, canvas: canvas);
    }
    if (isTimeLineMode) {
      drawPolyline(
        lastValue: lastValue,
        currentValue: currentValue,
        canvas: canvas,
      );
    } else if (indicator == CandlesIndicators.MA) {
      drawMaLine(
        lastValue: lastValue,
        currentValue: currentValue,
        canvas: canvas,
      );
    } else if (indicator == CandlesIndicators.BOLL) {
      drawBollLine(
        lastValue: lastValue,
        currentValue: currentValue,
        canvas: canvas,
      );
    }
  }

  void drawPolyline({
    required final Canvas canvas,
    required final RenderData<Candle> lastValue,
    required final RenderData<Candle> currentValue,
  }) {
    // Start filling point
    final lastXValue = lastValue.x == currentValue.x ? 0.0 : lastValue.x;

    final fillPath = Path();
    fillPath.moveTo(lastXValue, displayRect.height + displayRect.top);
    fillPath.lineTo(
      lastXValue,
      getVerticalPositionForPoint(value: lastValue.data.close),
    );
    fillPath.cubicTo(
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: lastValue.data.close),
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: currentValue.data.close),
      currentValue.x,
      getVerticalPositionForPoint(value: currentValue.data.close),
    );
    fillPath.lineTo(currentValue.x, displayRect.height + displayRect.top);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      // Shadows
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
        colors: [
          chartStyle.colors.lineFillColor,
          Colors.transparent,
        ],
      ).createShader(displayRect);
    canvas.drawPath(fillPath, fillPaint);

    final path = Path();
    path.moveTo(
      lastXValue,
      getVerticalPositionForPoint(value: lastValue.data.close),
    );
    path.cubicTo(
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: lastValue.data.close),
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: currentValue.data.close),
      currentValue.x,
      getVerticalPositionForPoint(value: currentValue.data.close),
    );
    canvas.drawPath(
      path,
      _timelinePaint
        ..strokeWidth = (1.0 / timelineHorizontalScale).clamp(0.1, 1.0),
    );
  }

  void drawMaLine({
    required final Canvas canvas,
    required final RenderData<Candle> lastValue,
    required final RenderData<Candle> currentValue,
  }) {
    for (var i = 0; i < currentValue.data.maValueList.length; i++) {
      if (i == 3) {
        break;
      }
      if (lastValue.data.maValueList[i] != 0) {
        drawLine(
          lastValue: RenderPoint(
            x: lastValue.x,
            y: lastValue.data.maValueList[i],
          ),
          currentValue: RenderPoint(
            x: currentValue.x,
            y: currentValue.data.maValueList[i],
          ),
          canvas: canvas,
          color: chartStyle.colors.getMAColor(i),
        );
      }
    }
  }

  void drawBollLine({
    required final Canvas canvas,
    required final RenderData<Candle> lastValue,
    required final RenderData<Candle> currentValue,
  }) {
    if (lastValue.data.top != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.top),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.top),
          canvas: canvas,
          color: chartStyle.colors.ma10Color);
    }
    if (lastValue.data.middle != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.middle),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.middle),
          canvas: canvas,
          color: chartStyle.colors.ma5Color);
    }
    if (lastValue.data.bottom != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.bottom),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.bottom),
          canvas: canvas,
          color: chartStyle.colors.ma30Color);
    }
  }

  void drawCandle({
    required final Canvas canvas,
    required final RenderData<Candle> candle,
  }) {
    final high = getVerticalPositionForPoint(value: candle.data.high);
    final low = getVerticalPositionForPoint(value: candle.data.low);
    var open = getVerticalPositionForPoint(value: candle.data.open);
    final close = getVerticalPositionForPoint(value: candle.data.close);
    final candleMidWidth = chartStyle.candleWidth * 0.5;
    final candleLineMidWidth = chartStyle.candleLineWidth * 0.5;

    if (open >= close) {
      // 实体高度>= CandleLineWidth
      if (open - close < chartStyle.candleLineWidth) {
        open = close + chartStyle.candleLineWidth;
      }
      chartPaint.color = chartStyle.colors.upColor;
      canvas.drawRect(
        Rect.fromLTRB(
          candle.x - candleMidWidth,
          close,
          candle.x + candleMidWidth,
          open,
        ),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(
          candle.x - candleLineMidWidth,
          high,
          candle.x + candleLineMidWidth,
          low,
        ),
        chartPaint,
      );
    } else if (close > open) {
      if (close - open < chartStyle.candleLineWidth) {
        open = close - chartStyle.candleLineWidth;
      }
      chartPaint.color = chartStyle.colors.dnColor;
      canvas.drawRect(
        Rect.fromLTRB(
          candle.x - candleMidWidth,
          open,
          candle.x + candleMidWidth,
          close,
        ),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(
          candle.x - candleLineMidWidth,
          high,
          candle.x + candleLineMidWidth,
          low,
        ),
        chartPaint,
      );
    }
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final TextStyle textStyle,
  }) {
    final rowSpace = displayRect.height / chartStyle.numberOfGridRows;
    for (var row = 0; row <= chartStyle.numberOfGridRows; ++row) {
      final value =
          (chartStyle.numberOfGridRows - row) * rowSpace / verticalScale +
              minVerticalValue;
      final rightText = TextSpan(
        text: '${format(n: value)}',
        style: textStyle,
      );
      final rightTextPainter = TextPainter(
        text: rightText,
        textDirection: TextDirection.ltr,
      );
      rightTextPainter.layout();
      if (row == 0) {
        rightTextPainter.paint(
          canvas,
          Offset(
            0,
            chartStyle.topPadding,
          ),
        );
      } else {
        rightTextPainter.paint(
          canvas,
          Offset(
            0,
            rowSpace * row - rightTextPainter.height + chartStyle.topPadding,
          ),
        );
      }
    }
  }

  @override
  void drawGrid({
    required final Canvas canvas,
  }) {
    final rowSpace = displayRect.height / chartStyle.numberOfGridRows;
    for (var row = 0; row <= chartStyle.numberOfGridRows; row++) {
      canvas.drawLine(
        Offset(0, rowSpace * row + chartStyle.topPadding),
        Offset(displayRect.width, rowSpace * row + chartStyle.topPadding),
        gridPaint,
      );
    }
    final columnSpace = displayRect.width / chartStyle.numberOfGridColumns;
    for (var i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, chartStyle.topPadding / 3),
        Offset(columnSpace * i, displayRect.bottom),
        gridPaint,
      );
    }
  }

  @override
  double getVerticalPositionForPoint({required double value}) {
    return (maxVerticalValue - value) * verticalScale + _contentRect.top;
  }
}
