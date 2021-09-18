import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

import 'base_chart_renderer.dart';

/// Volume indicator
class VolumeRenderer extends BaseChartRenderer<VolumeEntity> {
  VolumeRenderer({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required final int fixedDecimalsLength,
    required final ChartStyle chartStyle,
  }) : super(
          displayRect: displayRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          fixedDecimalsLength: fixedDecimalsLength,
          chartStyle: chartStyle,
        );

  @override
  void drawChart({
    required final Canvas canvas,
    required final RenderData<VolumeEntity> lastValue,
    required final RenderData<VolumeEntity> currentValue,
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

    if (lastValue.data.MA5Volume != 0) {
      drawLine(
        lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.MA5Volume),
        currentValue:
            RenderPoint(x: currentValue.x, y: currentValue.data.MA5Volume),
        canvas: canvas,
        color: chartStyle.colors.ma5Color,
      );
    }

    if (lastValue.data.MA10Volume != 0) {
      drawLine(
        lastValue: RenderPoint(
          x: lastValue.x,
          y: lastValue.data.MA10Volume,
        ),
        currentValue: RenderPoint(
          x: currentValue.x,
          y: currentValue.data.MA10Volume,
        ),
        canvas: canvas,
        color: chartStyle.colors.ma10Color,
      );
    }
  }

  @override
  void drawText({
    required final Canvas canvas,
    required final VolumeEntity value,
    required final double leftOffset,
  }) {
    final titles = TextSpan(
      children: [
        TextSpan(
          //TODO: Localize
          text: 'VOL:${NumberUtil.format(value.vol)}    ',
          style: getTextStyle(color: chartStyle.colors.volColor),
        ),
        if (value.MA5Volume.notNullOrZero)
          TextSpan(
            //TODO: Localize
            text: 'MA5:${NumberUtil.format(value.MA5Volume!)}    ',
            style: getTextStyle(color: chartStyle.colors.ma5Color),
          ),
        if (value.MA10Volume.notNullOrZero)
          TextSpan(
            //TODO: Localize
            text: 'MA10:${NumberUtil.format(value.MA10Volume!)}    ',
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
  }) {
    canvas.drawLine(
      Offset(0, displayRect.bottom),
      Offset(displayRect.width, displayRect.bottom),
      gridPaint,
    );
    final columnSpace = displayRect.width / chartStyle.numberOfGridColumns;
    for (var column = 0; column <= columnSpace; column++) {
      canvas.drawLine(
          Offset(
              columnSpace * column, displayRect.top - chartStyle.childPadding),
          Offset(columnSpace * column, displayRect.bottom),
          gridPaint);
    }
  }
}
