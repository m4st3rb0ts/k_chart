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
    required this.chartColors,
  }) : super(
          chartRect: mainRect,
          maxYValue: maxValue,
          minYValue: minValue,
          topPadding: topPadding,
          fixedDecimalsLength: fixedLength,
          gridColor: chartColors.gridColor,
        ) {
    mVolWidth = this.chartStyle.volWidth;
  }

  late double mVolWidth;
  final ChartStyle chartStyle;
  final ChartColors chartColors;

  @override
  void drawChart({
    required final VolumeEntity lastPoint,
    required final VolumeEntity curPoint,
    required final double lastX,
    required final double curX,
    required final Size size,
    required final Canvas canvas,
  }) {
    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;
    if (curPoint.vol != 0) {
      canvas.drawRect(
          Rect.fromLTRB(curX - r, top, curX + r, bottom),
          chartPaint
            ..color = curPoint.close > curPoint.open
                ? chartColors.upColor
                : chartColors.dnColor);
    }

    if (lastPoint.MA5Volume != 0) {
      drawLine(
        lastPrice: lastPoint.MA5Volume,
        curPrice: curPoint.MA5Volume,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
        color: chartColors.ma5Color,
      );
    }

    if (lastPoint.MA10Volume != 0) {
      drawLine(
        lastPrice: lastPoint.MA10Volume,
        curPrice: curPoint.MA10Volume,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
        color: chartColors.ma10Color,
      );
    }
  }

  double getVolY(double value) =>
      (maxYValue - value) * (chartRect.height / maxYValue) + chartRect.top;

  @override
  void drawText({
    required final Canvas canvas,
    required final VolumeEntity data,
    required final double x,
  }) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(
            text: "VOL:${NumberUtil.format(data.vol)}    ",
            style: getTextStyle(color: chartColors.volColor)),
        if (data.MA5Volume.notNullOrZero)
          TextSpan(
              text: "MA5:${NumberUtil.format(data.MA5Volume!)}    ",
              style: getTextStyle(color: chartColors.ma5Color)),
        if (data.MA10Volume.notNullOrZero)
          TextSpan(
              text: "MA10:${NumberUtil.format(data.MA10Volume!)}    ",
              style: getTextStyle(color: chartColors.ma10Color)),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required final int gridRows,
  }) {
    TextSpan span =
        TextSpan(text: "${NumberUtil.format(maxYValue)}", style: textStyle);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas, Offset(chartRect.width - tp.width, chartRect.top - topPadding));
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final int gridRows,
    required final int gridColumns,
  }) {
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
