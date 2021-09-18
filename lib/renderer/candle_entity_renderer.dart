import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show PrimaryIndicator;
import 'base_chart_renderer.dart';

class CandleEntityRender extends BaseChartRenderer<CandleEntity> {
  CandleEntityRender({
    required final Rect mainRect,
    required double maxVerticalValue,
    required double minVerticalValue,
    required final double contentTopPadding,
    required this.indicator,
    required this.isLine,
    required final int fixedDecimalsLength,
    required final ChartStyle chartStyle,
    required this.scaleX,
    this.maDayList = const [5, 10, 20],
  }) : super(
          displayRect: mainRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          contentTopPadding: contentTopPadding,
          fixedDecimalsLength: fixedDecimalsLength,
          chartStyle: chartStyle,
        ) {
    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = mLineStrokeWidth
      ..color = chartStyle.colors.kLineColor;
    _contentRect = Rect.fromLTRB(
        displayRect.left,
        displayRect.top + _contentPadding,
        displayRect.right,
        displayRect.bottom - _contentPadding);
    if (maxVerticalValue == minVerticalValue) {
      maxVerticalValue *= 1.5;
      minVerticalValue /= 2;
    }
    verticalScale = _contentRect.height / (maxVerticalValue - minVerticalValue);
  }

  /// Indicator that the candle graph should display (MA, BOLL)
  final PrimaryIndicator indicator;

  /// Display candle or lines
  final bool isLine;

  /// Draw content area
  late Rect _contentRect;
  final double _contentPadding = 5.0;

  List<int> maDayList;

  final double mLineStrokeWidth = 1.0;
  double scaleX;
  late Paint mLinePaint;

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void drawText({
    required final Canvas canvas,
    required final CandleEntity value,
    required final double leftOffset,
  }) {
    if (isLine == true) return;
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
                style: getTextStyle(color: chartStyle.colors.ma5Color)),
          if (value.mb != 0)
            TextSpan(
                // TODO: Localize
                text: "UB:${format(n: value.up)}    ",
                style: getTextStyle(color: chartStyle.colors.ma10Color)),
          if (value.dn != 0)
            TextSpan(
                // TODO: Localize
                text: "LB:${format(n: value.dn)}    ",
                style: getTextStyle(color: chartStyle.colors.ma30Color)),
        ],
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(leftOffset, displayRect.top - contentTopPadding));
  }

  List<InlineSpan> _createMATextSpan({required final CandleEntity data}) {
    var result = <InlineSpan>[];
    for (var i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        final item = TextSpan(
            //Localize
            text: "MA${maDayList[i]}:${format(n: data.maValueList![i])}    ",
            style: getTextStyle(color: chartStyle.colors.getMAColor(i)));
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
    if (!isLine) {
      drawCandle(candle: currentValue, canvas: canvas);
    }
    if (isLine) {
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
    mLinePath ??= Path();

    // Start filling point
    final lastXValue = lastValue.x == currentValue.x ? 0.0 : lastValue.x;
    mLinePath!.moveTo(
      lastXValue,
      getVerticalPositionForPoint(value: lastValue.data.close),
    );
    mLinePath!.cubicTo(
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: lastValue.data.close),
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: currentValue.data.close),
      currentValue.x,
      getVerticalPositionForPoint(value: currentValue.data.close),
    );

    // Shadows
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [chartStyle.colors.lineFillColor, Colors.transparent],
    ).createShader(Rect.fromLTRB(displayRect.left, displayRect.top,
        displayRect.right, displayRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath!.moveTo(lastXValue, displayRect.height + displayRect.top);
    mLineFillPath!.lineTo(
      lastXValue,
      getVerticalPositionForPoint(value: lastValue.data.close),
    );
    mLineFillPath!.cubicTo(
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: lastValue.data.close),
      (lastXValue + currentValue.x) * 0.5,
      getVerticalPositionForPoint(value: currentValue.data.close),
      currentValue.x,
      getVerticalPositionForPoint(value: currentValue.data.close),
    );
    mLineFillPath!.lineTo(currentValue.x, displayRect.height + displayRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();

    canvas.drawPath(mLinePath!,
        mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0));
    mLinePath!.reset();
  }

  void drawMaLine({
    required final RenderData<CandleEntity> lastValue,
    required final RenderData<CandleEntity> currentValue,
    required final Canvas canvas,
  }) {
    for (int i = 0; i < (currentValue.data.maValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      if (lastValue.data.maValueList?[i] != 0) {
        drawLine(
          lastValue:
              RenderPoint(x: lastValue.x, y: lastValue.data.maValueList?[i]),
          currentValue: RenderPoint(
              x: currentValue.x, y: currentValue.data.maValueList?[i]),
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
    double rowSpace = displayRect.height / chartStyle.gridRows;
    for (var i = 0; i <= chartStyle.gridRows; ++i) {
      double value = (chartStyle.gridRows - i) * rowSpace / verticalScale +
          minVerticalValue;
      TextSpan span = TextSpan(text: "${format(n: value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      if (i == 0) {
        tp.paint(canvas, Offset(0, contentTopPadding));
      } else {
        tp.paint(
            canvas, Offset(0, rowSpace * i - tp.height + contentTopPadding));
      }
    }
  }

  @override
  void drawGrid({
    required final Canvas canvas,
  }) {
    final rowSpace = displayRect.height / chartStyle.gridRows;
    for (int i = 0; i <= chartStyle.gridRows; i++) {
      canvas.drawLine(
          Offset(0, rowSpace * i + contentTopPadding),
          Offset(displayRect.width, rowSpace * i + contentTopPadding),
          gridPaint);
    }
    final columnSpace = displayRect.width / chartStyle.gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, contentTopPadding / 3),
          Offset(columnSpace * i, displayRect.bottom), gridPaint);
    }
  }

  @override
  double getVerticalPositionForPoint({required double value}) {
    return (maxVerticalValue - value) * verticalScale + _contentRect.top;
  }
}
