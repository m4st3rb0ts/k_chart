//
// Created by @OpenFlutter & @sh1l0n
//

import 'package:flutter/material.dart';

import '../indicator_renderer.dart';
import 'candles_indicator.dart';
import 'candle.dart';

/// Candle data render
class CandleEntityRender extends IndicatorRenderer<Candle> {
  CandleEntityRender({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required this.indicator,
    required this.isTimeLineMode,
    required final int fixedDecimalsLength,
    required this.timelineHorizontalScale,
    required final double titlesTopPadding,
    required this.candleLineWidth,
    required this.candleItemWidth,
    required this.lineFillColor,
    required this.gridColor,
    required this.kLineColor,
    required this.ma5Color,
    required this.ma10Color,
    required this.ma30Color,
    required this.upColor,
    required this.dnColor,
    required this.nowPriceUpColor,
    required this.nowPriceDnColor,
    required this.nowPriceTextColor,
    required this.maxColor,
    required this.minColor,
    required this.nowPriceLineLength,
    required this.nowPriceLineSpan,
    required this.maFactorsForTitles,
  }) : super(
          displayRect: displayRect,
          titlesTopPadding: titlesTopPadding,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          fixedDecimalsLength: fixedDecimalsLength,
          gridColor: gridColor,
        ) {
    _timelinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = kLineColor;
    _contentRect = Rect.fromLTRB(
      displayRect.left,
      displayRect.top + contentPadding + titlesTopPadding,
      displayRect.right,
      displayRect.bottom - contentPadding,
    );
    verticalScale = _contentRect.height / (maxVerticalValue - minVerticalValue);
  }

  final double candleLineWidth;
  final double candleItemWidth;
  final Color lineFillColor;
  final Color gridColor;
  final Color kLineColor;
  final Color ma5Color;
  final Color ma10Color;
  final Color ma30Color;
  final Color upColor;
  final Color dnColor;
  final Color nowPriceUpColor;
  final Color nowPriceDnColor;
  final Color nowPriceTextColor;
  final Color maxColor;
  final Color minColor;
  final double nowPriceLineLength;
  final double nowPriceLineSpan;

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

  Color _getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }

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
                color: ma5Color,
              ),
            ),
          if (value.middle != 0)
            TextSpan(
              // TODO: Localize
              text: 'UB:${format(n: value.top)}    ',
              style: getTextStyle(
                color: ma10Color,
              ),
            ),
          if (value.bottom != 0)
            TextSpan(
              // TODO: Localize
              text: 'LB:${format(n: value.bottom)}    ',
              style: getTextStyle(
                color: ma30Color,
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
        displayRect.top,
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
          style: getTextStyle(color: _getMAColor(i)),
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
          lineFillColor,
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
          color: _getMAColor(i),
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
          color: ma10Color);
    }
    if (lastValue.data.middle != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.middle),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.middle),
          canvas: canvas,
          color: ma5Color);
    }
    if (lastValue.data.bottom != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.bottom),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.bottom),
          canvas: canvas,
          color: ma30Color);
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
    final candleMidWidth = candleItemWidth * 0.5;
    final candleLineMidWidth = candleLineWidth * 0.5;

    if (open >= close) {
      // 实体高度>= CandleLineWidth
      if (open - close < candleLineWidth) {
        open = close + candleLineWidth;
      }
      chartPaint.color = upColor;
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
      if (close - open < candleLineWidth) {
        open = close - candleLineWidth;
      }
      chartPaint.color = dnColor;
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
    required final int numberOfGridRows,
    required final TextStyle textStyle,
  }) {
    final rowSpace = displayRect.height / numberOfGridRows;
    for (var row = 0; row <= numberOfGridRows; ++row) {
      final value = (numberOfGridRows - row) * rowSpace / verticalScale +
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
            titlesTopPadding,
          ),
        );
      } else {
        rightTextPainter.paint(
          canvas,
          Offset(
            0,
            rowSpace * row - rightTextPainter.height + titlesTopPadding,
          ),
        );
      }
    }
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final int numberOfGridColumns,
    required final int numberOfGridRows,
  }) {
    final rowSpace = displayRect.height / numberOfGridRows;
    for (var row = 0; row <= numberOfGridRows; row++) {
      canvas.drawLine(
        Offset(0, rowSpace * row + titlesTopPadding),
        Offset(displayRect.width, rowSpace * row + titlesTopPadding),
        gridPaint,
      );
    }
    final columnSpace = displayRect.width / numberOfGridColumns;
    for (var i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, titlesTopPadding / 3),
        Offset(columnSpace * i, displayRect.bottom + titlesTopPadding),
        gridPaint,
      );
    }
  }

  @override
  double getVerticalPositionForPoint({required double value}) {
    return (maxVerticalValue - value) * verticalScale + _contentRect.top;
  }
}
