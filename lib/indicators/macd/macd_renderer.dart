//
// Created by @OpenFlutter & @sh1l0n
//

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../chart_style.dart';
import '../indicator_renderer.dart';
import 'macd.dart';

class MacdRenderer extends IndicatorRenderer<Macd> {
  MacdRenderer({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required this.titleTopPadding,
    required this.indicator,
    required final int fixedDecimalsLength,
    required this.defaultTextColor,
    required this.macdColor,
    required this.difColor,
    required this.deaColor,
    required this.kColor,
    required this.dColor,
    required this.jColor,
    required this.rsiColor,
    required this.upColor,
    required this.dnColor,
  }) : super(
          displayRect: displayRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          fixedDecimalsLength: fixedDecimalsLength,
          chartStyle: ChartStyle(),
        );

  final MacdIndicators indicator;
  final double titleTopPadding;
  final Color defaultTextColor;
  final Color macdColor;
  final Color difColor;
  final Color deaColor;
  final Color kColor;
  final Color dColor;
  final Color jColor;
  final Color rsiColor;
  final Color upColor;
  final Color dnColor;

  @override
  void drawChart({
    required final Canvas canvas,
    required final RenderData<Macd> lastValue,
    required final RenderData<Macd> currentValue,
    required final Size size,
  }) {
    switch (indicator) {
      case MacdIndicators.MACD:
        drawMACD(
          lastValue: lastValue,
          currentValue: currentValue,
          canvas: canvas,
        );
        break;
      case MacdIndicators.KDJ:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.k),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.k),
          canvas: canvas,
          color: kColor,
        );
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.d),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.d),
          canvas: canvas,
          color: dColor,
        );
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.j),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.j),
          canvas: canvas,
          color: jColor,
        );
        break;
      case MacdIndicators.RSI:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.rsi),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.rsi),
          canvas: canvas,
          color: rsiColor,
        );
        break;
      case MacdIndicators.WR:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.r),
          currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.r),
          canvas: canvas,
          color: rsiColor,
        );
        break;
      case MacdIndicators.CCI:
        drawLine(
          lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.cci),
          currentValue:
              RenderPoint(x: currentValue.x, y: currentValue.data.cci),
          canvas: canvas,
          color: rsiColor,
        );
        break;
      default:
        break;
    }
  }

  void drawMACD({
    required final Canvas canvas,
    required final RenderData<Macd> lastValue,
    required final RenderData<Macd> currentValue,
  }) {
    final currentMacdValue = currentValue.data.macd;
    final currentMacdValueNormalized =
        getVerticalPositionForPoint(value: currentMacdValue);
    final macdMidWidth = chartStyle.macdWidth * 0.5;
    final zeroy = getVerticalPositionForPoint(value: 0);
    if (currentMacdValue > 0) {
      canvas.drawRect(
        Rect.fromLTRB(
          currentValue.x - macdMidWidth,
          currentMacdValueNormalized,
          currentValue.x + macdMidWidth,
          zeroy,
        ),
        chartPaint..color = upColor,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(
          currentValue.x - macdMidWidth,
          zeroy,
          currentValue.x + macdMidWidth,
          currentMacdValueNormalized,
        ),
        chartPaint..color = dnColor,
      );
    }
    if (lastValue.data.dif != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.dif),
        currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.dif),
        canvas: canvas,
        color: difColor,
      );
    }
    if (lastValue.data.dea != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.dea),
        currentValue: RenderPoint(x: currentValue.x, y: currentValue.data.dea),
        canvas: canvas,
        color: deaColor,
      );
    }
  }

  @override
  void drawText({
    required final Canvas canvas,
    required final Macd value,
    required final double leftOffset,
  }) {
    var titles = <TextSpan>[];
    switch (indicator) {
      case MacdIndicators.MACD:
        titles = [
          TextSpan(
            //TODO: Localize
            text: 'MACD(12,26,9)    ',
            style: getTextStyle(
              color: defaultTextColor,
            ),
          ),
          if (value.macd != 0)
            TextSpan(
              //TODO: Localize
              text: 'MACD:${format(n: value.macd)}    ',
              style: getTextStyle(
                color: macdColor,
              ),
            ),
          if (value.dif != 0)
            TextSpan(
              //TODO: Localize
              text: 'DIF:${format(n: value.dif)}    ',
              style: getTextStyle(
                color: difColor,
              ),
            ),
          if (value.dea != 0)
            TextSpan(
              //TODO: Localize
              text: 'DEA:${format(n: value.dea)}    ',
              style: getTextStyle(
                color: deaColor,
              ),
            ),
        ];
        break;
      case MacdIndicators.KDJ:
        titles = [
          TextSpan(
            //TODO: Localize
            text: 'KDJ(9,1,3)    ',
            style: getTextStyle(
              color: defaultTextColor,
            ),
          ),
          if (value.macd != 0)
            TextSpan(
              //TODO: Localize
              text: 'K:${format(n: value.k)}    ',
              style: getTextStyle(
                color: kColor,
              ),
            ),
          if (value.dif != 0)
            TextSpan(
              //TODO: Localize
              text: 'D:${format(n: value.d)}    ',
              style: getTextStyle(
                color: dColor,
              ),
            ),
          if (value.dea != 0)
            TextSpan(
              //TODO: Localize
              text: 'J:${format(n: value.j)}    ',
              style: getTextStyle(
                color: jColor,
              ),
            ),
        ];
        break;
      case MacdIndicators.RSI:
        titles = [
          TextSpan(
            //TODO: Localize
            text: 'RSI(14):${format(n: value.rsi)}    ',
            style: getTextStyle(
              color: rsiColor,
            ),
          ),
        ];
        break;
      case MacdIndicators.WR:
        titles = [
          TextSpan(
            //TODO: Localize
            text: 'WR(14):${format(n: value.r)}    ',
            style: getTextStyle(
              color: rsiColor,
            ),
          ),
        ];
        break;
      case MacdIndicators.CCI:
        titles = [
          TextSpan(
            //TODO: Localize
            text: 'CCI(14):${format(n: value.cci)}    ',
            style: getTextStyle(
              color: rsiColor,
            ),
          ),
        ];
        break;
      default:
        break;
    }
    final titlesPainter = TextPainter(
      text: TextSpan(
        children: titles,
      ),
      textDirection: TextDirection.ltr,
    );
    titlesPainter.layout();
    titlesPainter.paint(
      canvas,
      Offset(
        leftOffset,
        displayRect.top - chartStyle.childPadding,
      ),
    );
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final TextStyle textStyle,
  }) {
    final maxVerticalValuePainter = TextPainter(
      text: TextSpan(
        text: '${format(n: maxVerticalValue)}',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    final minVerticalValuePainter = TextPainter(
      text: TextSpan(
        text: '${format(n: minVerticalValue)}',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    maxVerticalValuePainter.layout();
    minVerticalValuePainter.layout();

    maxVerticalValuePainter.paint(
      canvas,
      Offset(
        displayRect.width - maxVerticalValuePainter.width,
        displayRect.top - chartStyle.childPadding,
      ),
    );
    minVerticalValuePainter.paint(
      canvas,
      Offset(
        displayRect.width - minVerticalValuePainter.width,
        displayRect.bottom - minVerticalValuePainter.height,
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
    final columnSpace = displayRect.width / chartStyle.numberOfGridColumns;
    for (var column = 0; column <= columnSpace; column++) {
      canvas.drawLine(
        Offset(columnSpace * column, displayRect.top - chartStyle.childPadding),
        Offset(columnSpace * column, displayRect.bottom),
        gridPaint,
      );
    }
  }

  @override
  void drawBackground({
    required final Canvas canvas,
    required Size size,
    required Gradient gradient,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(
        displayRect.left,
        displayRect.top,
        displayRect.width,
        displayRect.height + titleTopPadding,
      ),
      Paint()..shader = gradient.createShader(displayRect),
    );
  }
}
