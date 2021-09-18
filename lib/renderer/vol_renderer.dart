import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

class VolRenderer extends BaseChartRenderer<VolumeEntity> {
  VolRenderer({
    required final Rect mainRect,
    required final double maxValue,
    required final double minValue,
    required final double topPadding,
    required final int fixedLength,
    required this.chartStyle,
  }) : super(
          displayRect: mainRect,
          maxVerticalValue: maxValue,
          minVerticalValue: minValue,
          contentTopPadding: topPadding,
          fixedDecimalsLength: fixedLength,
          gridColor: chartStyle.colors.gridColor,
        ) {
    mVolWidth = this.chartStyle.volWidth;
  }

  late double mVolWidth;
  final ChartStyle chartStyle;

  @override
  void drawChart({
    required final RenderData<VolumeEntity> lastValue,
    required final RenderData<VolumeEntity> currentValue,
    required final Size size,
    required final Canvas canvas,
  }) {
    double r = mVolWidth / 2;
    double top = getVolY(currentValue.data.vol);
    double bottom = displayRect.bottom;
    if (currentValue.data.vol != 0) {
      canvas.drawRect(
          Rect.fromLTRB(currentValue.x - r, top, currentValue.x + r, bottom),
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
        lastValue: RenderPoint(x: lastValue.x, y: lastValue.data.MA10Volume),
        currentValue:
            RenderPoint(x: currentValue.x, y: currentValue.data.MA10Volume),
        canvas: canvas,
        color: chartStyle.colors.ma10Color,
      );
    }
  }

  double getVolY(double value) =>
      (maxVerticalValue - value) * (displayRect.height / maxVerticalValue) +
      displayRect.top;

  @override
  void drawText({
    required final Canvas canvas,
    required final VolumeEntity data,
    required final double leftOffset,
  }) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(
            text: "VOL:${NumberUtil.format(data.vol)}    ",
            style: getTextStyle(color: chartStyle.colors.volColor)),
        if (data.MA5Volume.notNullOrZero)
          TextSpan(
              text: "MA5:${NumberUtil.format(data.MA5Volume!)}    ",
              style: getTextStyle(color: chartStyle.colors.ma5Color)),
        if (data.MA10Volume.notNullOrZero)
          TextSpan(
              text: "MA10:${NumberUtil.format(data.MA10Volume!)}    ",
              style: getTextStyle(color: chartStyle.colors.ma10Color)),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(leftOffset, displayRect.top - contentTopPadding));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required final int gridRows,
  }) {
    TextSpan span = TextSpan(
        text: "${NumberUtil.format(maxVerticalValue)}", style: textStyle);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas,
        Offset(
            displayRect.width - tp.width, displayRect.top - contentTopPadding));
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final int numberOfRows,
    required final int numberOfColumns,
  }) {
    canvas.drawLine(Offset(0, displayRect.bottom),
        Offset(displayRect.width, displayRect.bottom), gridPaint);
    double columnSpace = displayRect.width / numberOfColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(
          Offset(columnSpace * i, displayRect.top - contentTopPadding),
          Offset(columnSpace * i, displayRect.bottom),
          gridPaint);
    }
  }
}
