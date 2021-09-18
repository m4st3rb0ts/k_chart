import 'dart:ui';

import 'package:flutter/material.dart';

import '../entity/macd_entity.dart';
import '../k_chart_widget.dart' show SecondaryIndicator;
import 'base_chart_renderer.dart';

class MACDEntityRenderer extends BaseChartRenderer<MACDEntity> {
  MACDEntityRenderer({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required final double contentTopPadding,
    required this.indicator,
    required final int fixedDecimalsLength,
    required final ChartStyle chartStyle,
  }) : super(
          displayRect: displayRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          contentTopPadding: contentTopPadding,
          fixedDecimalsLength: fixedDecimalsLength,
          chartStyle: chartStyle,
        );

  final SecondaryIndicator indicator;

  @override
  void drawChart({
    required final RenderData<MACDEntity> lastValue,
    required final RenderData<MACDEntity> currentValue,
    required final Size size,
    required final Canvas canvas,
  }) {
    switch (indicator) {
      case SecondaryIndicator.MACD:
        drawMACD(
          curPoint: currentValue.data,
          canvas: canvas,
          curX: currentValue.x,
          lastPoint: lastValue.data,
          lastX: lastValue.x,
        );
        break;
      case SecondaryIndicator.KDJ:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.k),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.k),
          canvas: canvas,
          color: chartStyle.colors.kColor,
        );
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.d),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.d),
          canvas: canvas,
          color: chartStyle.colors.dColor,
        );
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.j),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.j),
          canvas: canvas,
          color: chartStyle.colors.jColor,
        );
        break;
      case SecondaryIndicator.RSI:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.rsi),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.rsi),
          canvas: canvas,
          color: chartStyle.colors.rsiColor,
        );
        break;
      case SecondaryIndicator.WR:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.r),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.r),
          canvas: canvas,
          color: chartStyle.colors.rsiColor,
        );
        break;
      case SecondaryIndicator.CCI:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.cci),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.cci),
          canvas: canvas,
          color: chartStyle.colors.rsiColor,
        );
        break;
      default:
        break;
    }
  }

  void drawMACD({
    required final MACDEntity curPoint,
    required final Canvas canvas,
    required final double curX,
    required final MACDEntity lastPoint,
    required final double lastX,
  }) {
    final macd = curPoint.macd ?? 0;
    final macdY = getVerticalPositionForPoint(value: macd);
    final r = chartStyle.macdWidth * 0.5;
    final zeroy = getVerticalPositionForPoint(value: 0);
    if (macd > 0) {
      canvas.drawRect(
        Rect.fromLTRB(
          curX - r,
          macdY,
          curX + r,
          zeroy,
        ),
        chartPaint..color = chartStyle.colors.upColor,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(
          curX - r,
          zeroy,
          curX + r,
          macdY,
        ),
        chartPaint..color = chartStyle.colors.dnColor,
      );
    }
    if (lastPoint.dif != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastX, y: lastPoint.dif),
        currentValue: RenderPoint(x: curX, y: curPoint.dif),
        canvas: canvas,
        color: chartStyle.colors.difColor,
      );
    }
    if (lastPoint.dea != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastX, y: lastPoint.dea),
        currentValue: RenderPoint(x: curX, y: curPoint.dea),
        canvas: canvas,
        color: chartStyle.colors.deaColor,
      );
    }
  }

  @override
  void drawText({
    required final Canvas canvas,
    required final MACDEntity value,
    required final double leftOffset,
  }) {
    List<TextSpan>? children;
    switch (indicator) {
      case SecondaryIndicator.MACD:
        children = [
          TextSpan(
            //TODO: Localize
            text: "MACD(12,26,9)    ",
            style: getTextStyle(
              color: chartStyle.colors.defaultTextColor,
            ),
          ),
          if (value.macd != 0)
            TextSpan(
              //TODO: Localize
              text: "MACD:${format(n: value.macd)}    ",
              style: getTextStyle(
                color: chartStyle.colors.macdColor,
              ),
            ),
          if (value.dif != 0)
            TextSpan(
              //TODO: Localize
              text: "DIF:${format(n: value.dif)}    ",
              style: getTextStyle(
                color: chartStyle.colors.difColor,
              ),
            ),
          if (value.dea != 0)
            TextSpan(
              //TODO: Localize
              text: "DEA:${format(n: value.dea)}    ",
              style: getTextStyle(
                color: chartStyle.colors.deaColor,
              ),
            ),
        ];
        break;
      case SecondaryIndicator.KDJ:
        children = [
          TextSpan(
            //TODO: Localize
            text: "KDJ(9,1,3)    ",
            style: getTextStyle(
              color: chartStyle.colors.defaultTextColor,
            ),
          ),
          if (value.macd != 0)
            TextSpan(
              //TODO: Localize
              text: "K:${format(n: value.k)}    ",
              style: getTextStyle(
                color: chartStyle.colors.kColor,
              ),
            ),
          if (value.dif != 0)
            TextSpan(
              //TODO: Localize
              text: "D:${format(n: value.d)}    ",
              style: getTextStyle(
                color: chartStyle.colors.dColor,
              ),
            ),
          if (value.dea != 0)
            TextSpan(
              //TODO: Localize
              text: "J:${format(n: value.j)}    ",
              style: getTextStyle(
                color: chartStyle.colors.jColor,
              ),
            ),
        ];
        break;
      case SecondaryIndicator.RSI:
        children = [
          TextSpan(
            //TODO: Localize
            text: "RSI(14):${format(n: value.rsi)}    ",
            style: getTextStyle(
              color: chartStyle.colors.rsiColor,
            ),
          ),
        ];
        break;
      case SecondaryIndicator.WR:
        children = [
          TextSpan(
            //TODO: Localize
            text: "WR(14):${format(n: value.r)}    ",
            style: getTextStyle(
              color: chartStyle.colors.rsiColor,
            ),
          ),
        ];
        break;
      case SecondaryIndicator.CCI:
        children = [
          TextSpan(
            //TODO: Localize
            text: "CCI(14):${format(n: value.cci)}    ",
            style: getTextStyle(
              color: chartStyle.colors.rsiColor,
            ),
          ),
        ];
        break;
      default:
        break;
    }
    final TextPainter tp = TextPainter(
      text: TextSpan(
        children: children ?? [],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(leftOffset, displayRect.top - contentTopPadding));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final TextStyle textStyle,
  }) {
    final TextPainter maxTp = TextPainter(
      text: TextSpan(
        text: "${format(n: maxVerticalValue)}",
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    maxTp.layout();
    final TextPainter minTp = TextPainter(
      text: TextSpan(
        text: "${format(n: minVerticalValue)}",
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    minTp.layout();

    maxTp.paint(
      canvas,
      Offset(
        displayRect.width - maxTp.width,
        displayRect.top - contentTopPadding,
      ),
    );
    minTp.paint(
      canvas,
      Offset(
        displayRect.width - minTp.width,
        displayRect.bottom - minTp.height,
      ),
    );
  }

  @override
  void drawGrid({
    required final Canvas canvas,
  }) {
    canvas.drawLine(
      Offset(0, displayRect.top),
      Offset(displayRect.width, displayRect.top),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, displayRect.bottom),
      Offset(displayRect.width, displayRect.bottom),
      gridPaint,
    );
    final columnSpace = displayRect.width / chartStyle.gridColumns;
    for (var i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
          Offset(columnSpace * i, displayRect.top - contentTopPadding),
          Offset(columnSpace * i, displayRect.bottom),
          gridPaint);
    }
  }
}
