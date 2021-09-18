import 'dart:ui';

import 'package:flutter/material.dart';

import '../entity/macd_entity.dart';
import '../k_chart_widget.dart' show SecondaryState;
import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  SecondaryRenderer({
    required final Rect mainRect,
    required final double maxValue,
    required final double minValue,
    required final double topPadding,
    required this.state,
    required final int fixedLength,
    required this.chartStyle,
    required this.chartColors,
  }) : super(
          chartRect: mainRect,
          maxYValue: maxValue,
          minYValue: minValue,
          topPadding: topPadding,
          fixedDecimalsLength: fixedLength,
          gridColor: chartColors.gridColor,
        ) {
    mMACDWidth = chartStyle.macdWidth;
  }

  late double mMACDWidth;
  final SecondaryState state;
  final ChartStyle chartStyle;
  final ChartColors chartColors;

  @override
  void drawChart(
      {required final MACDEntity lastPoint,
      required final MACDEntity curPoint,
      required final double lastX,
      required final double curX,
      required final Size size,
      required final Canvas canvas}) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(
            curPoint: curPoint,
            canvas: canvas,
            curX: curX,
            lastPoint: lastPoint,
            lastX: lastX);
        break;
      case SecondaryState.KDJ:
        drawLine(
          lastPrice: lastPoint.k,
          curPrice: curPoint.k,
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.kColor,
        );
        drawLine(
          lastPrice: lastPoint.d,
          curPrice: curPoint.d,
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.dColor,
        );
        drawLine(
          lastPrice: lastPoint.j,
          curPrice: curPoint.j,
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.jColor,
        );
        break;
      case SecondaryState.RSI:
        drawLine(
            lastPrice: lastPoint.rsi,
            curPrice: curPoint.rsi,
            canvas: canvas,
            lastX: lastX,
            curX: curX,
            color: chartColors.rsiColor);
        break;
      case SecondaryState.WR:
        drawLine(
            lastPrice: lastPoint.r,
            curPrice: curPoint.r,
            canvas: canvas,
            lastX: lastX,
            curX: curX,
            color: chartColors.rsiColor);
        break;
      case SecondaryState.CCI:
        drawLine(
            lastPrice: lastPoint.cci,
            curPrice: curPoint.cci,
            canvas: canvas,
            lastX: lastX,
            curX: curX,
            color: chartColors.rsiColor);
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
    double macdY = getVerticalPositionForPoint(value: macd);
    double r = mMACDWidth / 2;
    double zeroy = getVerticalPositionForPoint(value: 0);
    if (macd > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = this.chartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = this.chartColors.dnColor);
    }
    if (lastPoint.dif != 0) {
      drawLine(
        lastPrice: lastPoint.dif,
        curPrice: curPoint.dif,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
        color: chartColors.difColor,
      );
    }
    if (lastPoint.dea != 0) {
      drawLine(
        lastPrice: lastPoint.dea,
        curPrice: curPoint.dea,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
        color: chartColors.deaColor,
      );
    }
  }

  @override
  void drawText({
    required final Canvas canvas,
    required final MACDEntity data,
    required final double x,
  }) {
    List<TextSpan>? children;
    switch (state) {
      case SecondaryState.MACD:
        children = [
          TextSpan(
              text: "MACD(12,26,9)    ",
              style: getTextStyle(color: chartColors.defaultTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "MACD:${format(n: data.macd)}    ",
                style: getTextStyle(color: chartColors.macdColor)),
          if (data.dif != 0)
            TextSpan(
                text: "DIF:${format(n: data.dif)}    ",
                style: getTextStyle(color: chartColors.difColor)),
          if (data.dea != 0)
            TextSpan(
                text: "DEA:${format(n: data.dea)}    ",
                style: getTextStyle(color: chartColors.deaColor)),
        ];
        break;
      case SecondaryState.KDJ:
        children = [
          TextSpan(
              text: "KDJ(9,1,3)    ",
              style: getTextStyle(color: chartColors.defaultTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "K:${format(n: data.k)}    ",
                style: getTextStyle(color: chartColors.kColor)),
          if (data.dif != 0)
            TextSpan(
                text: "D:${format(n: data.d)}    ",
                style: getTextStyle(color: chartColors.dColor)),
          if (data.dea != 0)
            TextSpan(
                text: "J:${format(n: data.j)}    ",
                style: getTextStyle(color: chartColors.jColor)),
        ];
        break;
      case SecondaryState.RSI:
        children = [
          TextSpan(
              text: "RSI(14):${format(n: data.rsi)}    ",
              style: getTextStyle(color: chartColors.rsiColor)),
        ];
        break;
      case SecondaryState.WR:
        children = [
          TextSpan(
              text: "WR(14):${format(n: data.r)}    ",
              style: getTextStyle(color: chartColors.rsiColor)),
        ];
        break;
      case SecondaryState.CCI:
        children = [
          TextSpan(
              text: "CCI(14):${format(n: data.cci)}    ",
              style: getTextStyle(color: chartColors.rsiColor)),
        ];
        break;
      default:
        break;
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children ?? []),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required final int gridRows,
  }) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${format(n: maxYValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${format(n: minYValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final int gridRows,
    required final int gridColumns,
  }) {
    canvas.drawLine(Offset(0, chartRect.top),
        Offset(chartRect.width, chartRect.top), gridPaint);
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
