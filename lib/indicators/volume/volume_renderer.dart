//
// Created by @OpenFlutter & @sh1l0n
//

import 'package:flutter/material.dart';
import 'package:k_chart/indicators/volume/volume.dart';

import '../../common.dart';
import '../../utils/number_util.dart';
import '../indicator_renderer.dart';
import 'volume.dart';

/// Volume indicator
class VolumeRenderer extends IndicatorRenderer<Volume> {
  VolumeRenderer({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required final int fixedDecimalsLength,
    required final double titlesTopPadding,
    required this.volumeItemWidth,
    required final Color gridColor,
    required this.ma10Color,
    required this.ma5Color,
    required this.volColor,
    required this.dnColor,
    required this.upColor,
  }) : super(
          displayRect: displayRect,
          titlesTopPadding: titlesTopPadding,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          fixedDecimalsLength: fixedDecimalsLength,
          gridColor: gridColor,
        );

  final double volumeItemWidth;
  final Color ma10Color;
  final Color ma5Color;
  final Color volColor;
  final Color dnColor;
  final Color upColor;

  @override
  void drawChart({
    required final Canvas canvas,
    required final RenderData<Volume> lastValue,
    required final RenderData<Volume> currentValue,
    required final Size size,
  }) {
    final volumeBarMidWidth = volumeItemWidth * 0.5;
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
                ? upColor
                : dnColor);
    }

    if (lastValue.data.ma5Volume != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.ma5Volume),
        currentValue:
            RenderPoint(x: currentValue.x, y: currentValue.data.ma5Volume),
        canvas: canvas,
        color: ma5Color,
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
        color: ma10Color,
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
          style: getTextStyle(color: volColor),
        ),
        if (value.ma5Volume.notNullOrZero)
          TextSpan(
            //TODO: Localize
            text: 'MA5:${NumberUtil.format(value.ma5Volume)}    ',
            style: getTextStyle(color: ma5Color),
          ),
        if (value.ma10Volume.notNullOrZero)
          TextSpan(
            //TODO: Localize
            text: 'MA10:${NumberUtil.format(value.ma10Volume)}    ',
            style: getTextStyle(color: ma10Color),
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
          displayRect.top - titlesTopPadding,
        ));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final int numberOfGridRows,
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
        displayRect.top - titlesTopPadding,
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

  @override
  void drawMaxAndMin({
    required final Canvas canvas,
    required final Size size,
  }) {}

  @override
  void drawLastPrice({
    required final Canvas canvas,
    required final Size size,
  }) {}
}
