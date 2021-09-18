import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

class VolumeRenderer extends BaseChartRenderer<VolumeEntity> {
  VolumeRenderer({
    required final Rect displayRect,
    required final double maxVerticalValue,
    required final double minVerticalValue,
    required final double contentTopPadding,
    required final int fixedDecimalsLength,
    required this.chartStyle,
  }) : super(
          displayRect: displayRect,
          maxVerticalValue: maxVerticalValue,
          minVerticalValue: minVerticalValue,
          contentTopPadding: contentTopPadding,
          fixedDecimalsLength: fixedDecimalsLength,
          gridColor: chartStyle.colors.gridColor,
        );

  final ChartStyle chartStyle;

  @override
  void drawChart({
    required final RenderData<VolumeEntity> lastValue,
    required final RenderData<VolumeEntity> currentValue,
    required final Size size,
    required final Canvas canvas,
  }) {
    final volumeBarWidth = chartStyle.volWidth / 2;
    final volumeBarTop = (maxVerticalValue - currentValue.data.vol) *
            (displayRect.height / maxVerticalValue) +
        displayRect.top;
    final volumeBarBottom = displayRect.bottom;
    if (currentValue.data.vol != 0) {
      canvas.drawRect(
          Rect.fromLTRB(
            currentValue.x - volumeBarWidth,
            volumeBarTop,
            currentValue.x + volumeBarWidth,
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
    final TextSpan span = TextSpan(
      children: [
        TextSpan(
          text: "VOL:${NumberUtil.format(value.vol)}    ",
          style: getTextStyle(color: chartStyle.colors.volColor),
        ),
        if (value.MA5Volume.notNullOrZero)
          TextSpan(
            text: "MA5:${NumberUtil.format(value.MA5Volume!)}    ",
            style: getTextStyle(color: chartStyle.colors.ma5Color),
          ),
        if (value.MA10Volume.notNullOrZero)
          TextSpan(
            text: "MA10:${NumberUtil.format(value.MA10Volume!)}    ",
            style: getTextStyle(color: chartStyle.colors.ma10Color),
          ),
      ],
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
        canvas,
        Offset(
          leftOffset,
          displayRect.top - contentTopPadding,
        ));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required final int numberOfRows,
  }) {
    final TextSpan span = TextSpan(
      text: "${NumberUtil.format(maxVerticalValue)}",
      style: textStyle,
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        displayRect.width - tp.width,
        displayRect.top - contentTopPadding,
      ),
    );
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final int numberOfRows,
    required final int numberOfColumns,
  }) {
    canvas.drawLine(
      Offset(0, displayRect.bottom),
      Offset(displayRect.width, displayRect.bottom),
      gridPaint,
    );
    final columnSpace = displayRect.width / numberOfColumns;
    for (var i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
          Offset(columnSpace * i, displayRect.top - contentTopPadding),
          Offset(columnSpace * i, displayRect.bottom),
          gridPaint);
    }
  }
}
