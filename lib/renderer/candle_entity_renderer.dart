import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show PrimaryIndicator;
import 'base_chart_renderer.dart';

class CandleEntityRender extends BaseChartRenderer<CandleEntity> {
  CandleEntityRender({
    required final Rect displayRect,
    required double maxVerticalValue,
    required double minVerticalValue,
    required final double contentTopPadding,
    required this.indicator,
    required this.isTimeLineMode,
    required final int fixedDecimalsLength,
    required final ChartStyle chartStyle,
    required this.timelineHorizontalScale,
    this.maDayList = const [5, 10, 20],
  }) : super(
          displayRect: displayRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          contentTopPadding: contentTopPadding,
          fixedDecimalsLength: fixedDecimalsLength,
          chartStyle: chartStyle,
        ) {
    timelinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = timelineStrokeWidth
      ..color = chartStyle.colors.kLineColor;
    _contentRect = Rect.fromLTRB(
      displayRect.left,
      displayRect.top + contentPadding,
      displayRect.right,
      displayRect.bottom - contentPadding,
    );
    if (maxVerticalValue == minVerticalValue) {
      maxVerticalValue *= 1.5;
      minVerticalValue /= 2;
    }
    verticalScale = _contentRect.height / (maxVerticalValue - minVerticalValue);
  }

  /// Indicator which together the candle graph should display (MA, BOLL, NONE)
  final PrimaryIndicator indicator;

  /// Display timeline or candle mode
  final bool isTimeLineMode;

  /// Draw content area
  late Rect _contentRect;

  /// Padding for content
  final double contentPadding = 5.0;

  List<int> maDayList;

  /// Line stroke width used for isLine mode
  final double timelineStrokeWidth = 1.0;

  /// Paint to use for time isLine mode
  late Paint timelinePaint;

  // Horizontal scale to use with timeline mode
  double timelineHorizontalScale;

  @override
  void drawText({
    required final Canvas canvas,
    required final CandleEntity value,
    required final double leftOffset,
  }) {
    if (isTimeLineMode == true) {
      return;
    }
    TextSpan? span;
    if (indicator == PrimaryIndicator.MA) {
      span = TextSpan(
        children: _createMATextSpan(data: value),
      );
    } else if (indicator == PrimaryIndicator.BOLL) {
      span = TextSpan(
        children: [
          if (value.up != 0)
            TextSpan(
              // TODO: Localize
              text: "BOLL:${format(n: value.mb)}    ",
              style: getTextStyle(
                color: chartStyle.colors.ma5Color,
              ),
            ),
          if (value.mb != 0)
            TextSpan(
              // TODO: Localize
              text: "UB:${format(n: value.up)}    ",
              style: getTextStyle(
                color: chartStyle.colors.ma10Color,
              ),
            ),
          if (value.dn != 0)
            TextSpan(
              // TODO: Localize
              text: "LB:${format(n: value.dn)}    ",
              style: getTextStyle(
                color: chartStyle.colors.ma30Color,
              ),
            ),
        ],
      );
    }
    if (span == null) {
      return;
    }
    final textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        leftOffset,
        displayRect.top - contentTopPadding,
      ),
    );
  }

  List<InlineSpan> _createMATextSpan({required final CandleEntity data}) {
    var result = <InlineSpan>[];
    for (var i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        final item = TextSpan(
          //Localize
          text: "MA${maDayList[i]}:${format(n: data.maValueList![i])}    ",
          style: getTextStyle(
            color: chartStyle.colors.getMAColor(i),
          ),
        );
        result.add(item);
      }
    }
    return result;
  }

  @override
  void drawChart({
    required final RenderData<CandleEntity> lastValue,
    required final RenderData<CandleEntity> currentValue,
    required final Size size,
    required final Canvas canvas,
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
    } else if (indicator == PrimaryIndicator.MA) {
      drawMaLine(
        lastValue: lastValue,
        currentValue: currentValue,
        canvas: canvas,
      );
    } else if (indicator == PrimaryIndicator.BOLL) {
      drawBollLine(
        lastValue: lastValue,
        currentValue: currentValue,
        canvas: canvas,
      );
    }
  }

  drawPolyline({
    required final RenderData<CandleEntity> lastValue,
    required final RenderData<CandleEntity> currentValue,
    required final Canvas canvas,
  }) {
    var path = Path();
    var fillPath = Path();
    Shader? fillShader;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Start filling point
    final lastXValue = lastValue.x == currentValue.x ? 0.0 : lastValue.x;
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

    // Shadows
    fillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [chartStyle.colors.lineFillColor, Colors.transparent],
    ).createShader(Rect.fromLTRB(displayRect.left, displayRect.top,
        displayRect.right, displayRect.bottom));
    fillPaint..shader = fillShader;

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

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(
        path,
        timelinePaint
          ..strokeWidth =
              (timelineStrokeWidth / timelineHorizontalScale).clamp(0.1, 1.0));
  }

  void drawMaLine({
    required final RenderData<CandleEntity> lastValue,
    required final RenderData<CandleEntity> currentValue,
    required final Canvas canvas,
  }) {
    for (var i = 0; i < (currentValue.data.maValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      if (lastValue.data.maValueList?[i] != 0) {
        drawLine(
          lastValue: RenderPoint(
            x: lastValue.x,
            y: lastValue.data.maValueList?[i],
          ),
          currentValue: RenderPoint(
            x: currentValue.x,
            y: currentValue.data.maValueList?[i],
          ),
          canvas: canvas,
          color: chartStyle.colors.getMAColor(i),
        );
      }
    }
  }

  void drawBollLine({
    required final RenderData<CandleEntity> lastValue,
    required final RenderData<CandleEntity> currentValue,
    required final Canvas canvas,
  }) {
    if (lastValue.data.up != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.up),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.up),
          canvas: canvas,
          color: chartStyle.colors.ma10Color);
    }
    if (lastValue.data.mb != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.mb),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.mb),
          canvas: canvas,
          color: chartStyle.colors.ma5Color);
    }
    if (lastValue.data.dn != 0) {
      drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.dn),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.dn),
          canvas: canvas,
          color: chartStyle.colors.ma30Color);
    }
  }

  void drawCandle({
    required final RenderData<CandleEntity> candle,
    required final Canvas canvas,
  }) {
    final high = getVerticalPositionForPoint(value: candle.data.high);
    final low = getVerticalPositionForPoint(value: candle.data.low);
    var open = getVerticalPositionForPoint(value: candle.data.open);
    final close = getVerticalPositionForPoint(value: candle.data.close);
    final r = chartStyle.candleWidth * 0.5;
    final lineR = chartStyle.candleLineWidth * 0.5;
    if (open >= close) {
      // 实体高度>= CandleLineWidth
      if (open - close < chartStyle.candleLineWidth) {
        open = close + chartStyle.candleLineWidth;
      }
      chartPaint.color = chartStyle.colors.upColor;
      canvas.drawRect(
        Rect.fromLTRB(candle.x - r, close, candle.x + r, open),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(candle.x - lineR, high, candle.x + lineR, low),
        chartPaint,
      );
    } else if (close > open) {
      if (close - open < chartStyle.candleLineWidth) {
        open = close - chartStyle.candleLineWidth;
      }
      chartPaint.color = chartStyle.colors.dnColor;
      canvas.drawRect(
        Rect.fromLTRB(candle.x - r, open, candle.x + r, close),
        chartPaint,
      );
      canvas.drawRect(
        Rect.fromLTRB(candle.x - lineR, high, candle.x + lineR, low),
        chartPaint,
      );
    }
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final TextStyle textStyle,
  }) {
    final rowSpace = displayRect.height / chartStyle.gridRows;
    for (var i = 0; i <= chartStyle.gridRows; ++i) {
      final value = (chartStyle.gridRows - i) * rowSpace / verticalScale +
          minVerticalValue;
      final textSpan = TextSpan(
        text: "${format(n: value)}",
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      if (i == 0) {
        textPainter.paint(
          canvas,
          Offset(
            0,
            contentTopPadding,
          ),
        );
      } else {
        textPainter.paint(
          canvas,
          Offset(
            0,
            rowSpace * i - textPainter.height + contentTopPadding,
          ),
        );
      }
    }
  }

  @override
  void drawGrid({
    required final Canvas canvas,
  }) {
    final rowSpace = displayRect.height / chartStyle.gridRows;
    for (var i = 0; i <= chartStyle.gridRows; i++) {
      canvas.drawLine(
        Offset(0, rowSpace * i + contentTopPadding),
        Offset(displayRect.width, rowSpace * i + contentTopPadding),
        gridPaint,
      );
    }
    final columnSpace = displayRect.width / chartStyle.gridColumns;
    for (var i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, contentTopPadding / 3),
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
