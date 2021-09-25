//
// Created by @OpenFlutter & @sh1l0n
//

import 'dart:ui';

import 'package:flutter/material.dart';
import 'volume.dart';

import '../../chart_style.dart';
import '../../common.dart';
import '../../utils/number_util.dart';
import '../indicator_renderer.dart';

/// Volume indicator
class VolumeRenderer extends IndicatorRenderer<Volume> {
  VolumeRenderer({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required final int fixedDecimalsLength,
    required final double titlesTopPadding,
    required this.chartStyle,
  }) : super(
          displayRect: displayRect,
          titlesTopPadding: titlesTopPadding,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          fixedDecimalsLength: fixedDecimalsLength,
          gridColor: chartStyle.colors.gridColor,
        );

  final ChartStyle chartStyle;

  @override
  void drawChart({
    required final Canvas canvas,
    required final RenderData<Volume> lastValue,
    required final RenderData<Volume> currentValue,
    required final Size size,
  }) {
    final volumeBarMidWidth = chartStyle.volWidth * 0.5;
    final volumeBarTop = (maxVerticalValue - currentValue.data.vol) *
            (displayRect.height / maxVerticalValue) +
        displayRect.top;
    final volumeBarBottom = displayRect.bottom;
    if (currentValue.data.vol != 0) {
      canvas.drawRect(
          Rect.fromLTRB(
            currentValue.x - volumeBarMidWidth,
            volumeBarTop,
            currentValue.x + volumeBarMidWidth,
            volumeBarBottom,
          ),
          chartPaint
            ..color = currentValue.data.close > currentValue.data.open
                ? chartStyle.colors.upColor
                : chartStyle.colors.dnColor);
    }

    if (lastValue.data.ma5Volume != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.ma5Volume),
        currentValue:
            RenderPoint(x: currentValue.x, y: currentValue.data.ma5Volume),
        canvas: canvas,
        color: chartStyle.colors.ma5Color,
      );
    }

    if (lastValue.data.ma10Volume != 0) {
      drawLine(
        lastValue: RenderPoint(
          x: lastValue.x,
          y: lastValue.data.ma10Volume,
        ),
        currentValue: RenderPoint(
          x: currentValue.x,
          y: currentValue.data.ma10Volume,
        ),
        canvas: canvas,
        color: chartStyle.colors.ma10Color,
      );
    }
  }

  @override
  void drawText({
    required final Canvas canvas,
    required final Volume value,
    required final double leftOffset,
  }) {
    final titles = TextSpan(
      children: [
        TextSpan(
          //TODO: Localize
          text: 'VOL:${NumberUtil.format(value.vol)}    ',
          style: getTextStyle(color: chartStyle.colors.volColor),
        ),
        if (value.ma5Volume.notNullOrZero)
          TextSpan(
            //TODO: Localize
            text: 'MA5:${NumberUtil.format(value.ma5Volume)}    ',
            style: getTextStyle(color: chartStyle.colors.ma5Color),
          ),
        if (value.ma10Volume.notNullOrZero)
          TextSpan(
            //TODO: Localize
            text: 'MA10:${NumberUtil.format(value.ma10Volume)}    ',
            style: getTextStyle(color: chartStyle.colors.ma10Color),
          ),
      ],
    );
    final titlesPainter = TextPainter(
      text: titles,
      textDirection: TextDirection.ltr,
    );
    titlesPainter.layout();
    titlesPainter.paint(
        canvas,
        Offset(
          leftOffset,
          displayRect.top - chartStyle.childPadding,
        ));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final TextStyle textStyle,
  }) {
    final rightText = TextSpan(
      text: '${NumberUtil.format(maxVerticalValue)}',
      style: textStyle,
    );
    final rightTextPainter = TextPainter(
      text: rightText,
      textDirection: TextDirection.ltr,
    );
    rightTextPainter.layout();
    rightTextPainter.paint(
      canvas,
      Offset(
        displayRect.width - rightTextPainter.width,
        displayRect.top - chartStyle.childPadding,
      ),
    );
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
}
