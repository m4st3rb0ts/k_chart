//
// Created by @OpenFlutter & @sh1l0n
//

import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../ticker/ticker.dart';
import '../entity/info_window_entity.dart';
import '../indicators/indicator.dart';
import '../../common.dart';
import 'base_chart_painter.dart';

class ChartPainter extends BaseChartPainter {
  ChartPainter({
    required this.indicators,
    required final List<Ticker> dataSource,
    required final intl.DateFormat displayDateFormat,
    required final double horizontalScale,
    required final double currentHorizontalScroll,
    required final bool shouldDisplaySelection,
    required final double selectedHorizontalValue,
    this.sink,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.fixedLength = 2,
    final double pointWidth = 11.0,
    this.nowPriceLineWidth = 1,
    this.childPadding = 12.0,
    this.topPadding = 30.0,
    this.bottomPadding = 20.0,
    this.selectedFillColor = const Color(0xff0D1722),
    this.selectedBorderColor = const Color(0xff6C7A86),
    this.backgroundGradientColors = const [
      Color(0xff18191d),
      Color(0xff18191d)
    ],
    this.numberOfGridColumns = 4,
    this.numberOfGridRows = 4,
    this.crossTextColor = const Color(0xffffffff),
    this.vCrossColor = const Color(0x1Effffff),
    this.vCrossWidth = 8.5,
    this.hCrossColor = const Color(0xffffffff),
    this.hCrossWidth = 0.5,
  }) : super(
          pointWidth: pointWidth,
          dataSource: dataSource,
          displayDateFormat: displayDateFormat,
          horizontalScale: horizontalScale,
          currentHorizontalScroll: currentHorizontalScroll,
          shouldDisplaySelection: shouldDisplaySelection,
          selectedHorizontalValue: selectedHorizontalValue,
        ) {
    selectPointPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..color = selectedFillColor;
    selectorBorderPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..color = selectedBorderColor;
    nowPricePaint = Paint()
      ..strokeWidth = nowPriceLineWidth
      ..isAntiAlias = true;
  }

  final double nowPriceLineWidth;
  final double childPadding;
  final double topPadding;
  final double bottomPadding;
  final Color selectedFillColor;
  final Color selectedBorderColor;
  final List<Color> backgroundGradientColors;
  final int numberOfGridColumns;
  final int numberOfGridRows;
  final Color crossTextColor;
  final Color vCrossColor;
  final double vCrossWidth;
  final Color hCrossColor;
  final double hCrossWidth;

  final List<Indicator> indicators;
  StreamSink<InfoWindowEntity?>? sink;
  Color? upColor, dnColor;
  Color? ma5Color, ma10Color, ma30Color;
  Color? volColor;
  Color? macdColor, difColor, deaColor, jColor;
  int fixedLength;
  late Paint selectPointPaint, selectorBorderPaint, nowPricePaint;
  final bool hideGrid;
  final bool showNowPrice;

  @override
  void initChartRenderer({required final Size size}) {
    if (dataSource.isNotEmpty) {
      final t = dataSource.first;
      fixedLength =
          NumberUtil.getMaxDecimalLength(t.open, t.close, t.high, t.low);
    }
    var displayRectTop = 0.0;
    for (final indicator in indicators) {
      indicator.updateRender(
        size: size,
        displayRectTop: displayRectTop,
        scale: horizontalScale,
        firstIndexToDisplay: mStartIndex,
        finalIndexToDisplay: mStopIndex,
      );
      displayRectTop += indicator.height + childPadding;
    }
  }

  @override
  void drawBackground(
      {required final Canvas canvas, required final Size size}) {
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: backgroundGradientColors,
    );

    for (final indicator in indicators) {
      indicator.render
          ?.drawBackground(canvas: canvas, size: size, gradient: mBgGradient);
    }
    Rect dateRect =
        Rect.fromLTRB(0, size.height - bottomPadding, size.width, size.height);
    canvas.drawRect(
        dateRect, mBgPaint..shader = mBgGradient.createShader(dateRect));
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final Size size,
  }) {
    if (!hideGrid) {
      for (final indicator in indicators) {
        indicator.render?.drawGrid(
          canvas: canvas,
          numberOfGridColumns: numberOfGridColumns,
          numberOfGridRows: numberOfGridRows,
        );
      }
    }
  }

  @override
  void drawChart({required final Canvas canvas, required final Size size}) {
    canvas.save();
    canvas.translate(getCurrentOffset(size: size) * horizontalScale, 0.0);
    canvas.scale(horizontalScale, 1.0);
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      final curX = getLeftOffsetByIndex(index: i);
      final lastX = i == 0 ? curX : getLeftOffsetByIndex(index: i - 1);
      for (final indicator in indicators) {
        final currentItem = indicator.data[i];
        final lastItem = indicator.data[i == 0 ? i : i - 1];
        indicator.render?.drawChart(
          lastValue: indicator.getRenderData(lastItem, lastX),
          currentValue: indicator.getRenderData(currentItem, curX),
          size: size,
          canvas: canvas,
        );
      }
    }

    canvas.restore();
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final Size size,
  }) {
    var textStyle = getTextStyle(
      color: const Color(0xff60738E),
    );
    if (!hideGrid) {
      for (final indicator in indicators) {
        indicator.render?.drawRightText(
          canvas: canvas,
          numberOfGridRows: numberOfGridRows,
          textStyle: textStyle,
        );
      }
    }
  }

  @override
  void drawDate({required final Canvas canvas, required final Size size}) {
    double columnSpace = size.width / numberOfGridColumns;
    double startX = getLeftOffsetByIndex(index: mStartIndex) - pointWidth * 0.5;
    double stopX = getLeftOffsetByIndex(index: mStopIndex) + pointWidth * 0.5;
    double x = 0.0;
    double y = 0.0;
    for (var i = 0; i <= numberOfGridColumns; ++i) {
      double translateX =
          translateToCurrentViewport(leftOffset: columnSpace * i, size: size);

      if (translateX >= startX && translateX <= stopX) {
        int index = dataIndexInViewportFor(leftOffset: translateX);

        final item = getDataItemByIndex(index: index);
        if (item == null) {
          return;
        }
        TextPainter tp = getTextPainter(getDate(item.time), null);
        y = size.height - (bottomPadding - tp.height) / 2 - tp.height;
        x = columnSpace * i - tp.width / 2;
        // Prevent date text out of canvas
        if (x < 0) x = 0;
        if (x > size.width - tp.width) x = size.width - tp.width;
        tp.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  void drawCrossLineText(
      {required final Canvas canvas, required final Size size}) {
    final index = getIndexForSelectedHorizontalValue(size: size);
    Ticker? point = getDataItemByIndex(index: index);
    if (point == null) {
      return;
    }

    TextPainter tp = getTextPainter(point.close, crossTextColor);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;

    if (computeTranslationFor(
            leftOffset: getLeftOffsetByIndex(index: index), size: size) <
        size.width / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = size.width - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(size.width - 2, y + r);
      path.lineTo(size.width - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter dateTp = getTextPainter(getDate(point.time), crossTextColor);
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = computeTranslationFor(
        leftOffset: getLeftOffsetByIndex(index: index), size: size);
    y = size.height - bottomPadding;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (size.width - x < textWidth + 2 * w1) {
      x = size.width - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectPointPaint);
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectorBorderPaint);

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));
    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft: isLeft));
  }

  @override
  void drawText({
    required final Canvas canvas,
    required final Size size,
    required final Ticker data,
    required final double x,
  }) {
    //长按显示按中的数据
    Ticker? customData = data;
    var index = 0;
    if (shouldDisplaySelection) {
      index = getIndexForSelectedHorizontalValue(size: size);
      customData = getDataItemByIndex(index: index);
      if (customData == null) {
        //TODO: Review if return or assign to data
        return;
      }
    } else {
      final offset = getCurrentOffset(size: size);
      index = dataIndexInViewportFor(leftOffset: -offset);
    }
    //松开显示最后一条数据
    for (final indicator in indicators) {
      indicator.render?.drawText(
          canvas: canvas, value: indicator.data[index], leftOffset: x);
    }
  }

  @override
  void drawMaxAndMin({required final Canvas canvas, required final Size size}) {
    // if (candlesIndicator.render?.isTimeLineMode ?? false) {
    //   return;
    // }
    // //绘制最大值和最小值
    // double x = translateXtoX(
    //     translateX: getLeftOffsetByIndex(
    //         index: candlesIndicator.currentItemIndexWithMinValue),
    //     size: size);
    // double y = getMainY(candlesIndicator.currentMinLowValue);
    // if (x < size.width / 2) {
    //   //画右边
    //   TextPainter tp = getTextPainter(
    //       "── " +
    //           candlesIndicator.currentMinLowValue.toStringAsFixed(fixedLength),
    //       chartStyle.colors.minColor);
    //   tp.paint(canvas, Offset(x, y - tp.height / 2));
    // } else {
    //   TextPainter tp = getTextPainter(
    //       candlesIndicator.currentMinLowValue.toStringAsFixed(fixedLength) +
    //           " ──",
    //       chartStyle.colors.minColor);
    //   tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    // }
    // x = translateXtoX(
    //     translateX: getLeftOffsetByIndex(
    //         index: candlesIndicator.currentItemIndexWithMaxValue),
    //     size: size);
    // y = getMainY(candlesIndicator.currentMaxHighValue);
    // if (x < size.width / 2) {
    //   //画右边
    //   TextPainter tp = getTextPainter(
    //       "── " +
    //           candlesIndicator.currentMaxHighValue.toStringAsFixed(fixedLength),
    //       chartStyle.colors.maxColor);
    //   tp.paint(canvas, Offset(x, y - tp.height / 2));
    // } else {
    //   TextPainter tp = getTextPainter(
    //       candlesIndicator.currentMaxHighValue.toStringAsFixed(fixedLength) +
    //           " ──",
    //       chartStyle.colors.maxColor);
    //   tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    // }
  }

  @override
  void drawNowPrice({required final Canvas canvas, required final Size size}) {
    // if (!showNowPrice) {
    //   return;
    // }

    // if (dataSource.isEmpty) {
    //   return;
    // }

    // double value = dataSource.last.close;
    // double y = getMainY(value);
    // //不在视图展示区域不绘制
    // if (y > getMainY(candlesIndicator.currentMinLowValue) ||
    //     y < getMainY(candlesIndicator.currentMaxHighValue)) {
    //   return;
    // }
    // nowPricePaint
    //   ..color = value >= dataSource.last.open
    //       ? chartStyle.colors.nowPriceUpColor
    //       : chartStyle.colors.nowPriceDnColor;
    // //先画横线
    // double startX = 0;
    // final max = -getCurrentOffset(size: size) + size.width / horizontalScale;
    // final space = chartStyle.nowPriceLineSpan + chartStyle.nowPriceLineLength;
    // while (startX < max) {
    //   canvas.drawLine(Offset(startX, y),
    //       Offset(startX + chartStyle.nowPriceLineLength, y), nowPricePaint);
    //   startX += space;
    // }
    // //再画背景和文本
    // TextPainter tp = getTextPainter(value.toStringAsFixed(fixedLength),
    //     chartStyle.colors.nowPriceTextColor);
    // double left = 0;
    // double top = y - tp.height / 2;
    // canvas.drawRect(Rect.fromLTRB(left, top, left + tp.width, top + tp.height),
    //     nowPricePaint);
    // tp.paint(canvas, Offset(0, top));
  }

  ///画交叉线
  void drawCrossLine({required final Canvas canvas, required final Size size}) {
    var index = getIndexForSelectedHorizontalValue(size: size);
    final point = getDataItemByIndex(index: index);
    if (point == null) {
      return;
    }

    Paint paintY = Paint()
      ..color = vCrossColor
      ..strokeWidth = vCrossWidth
      ..isAntiAlias = true;
    double x = getLeftOffsetByIndex(index: index);
    double y = getMainY(point.close);
    // k线图竖线
    canvas.drawLine(
        Offset(x, topPadding), Offset(x, size.height - bottomPadding), paintY);

    Paint paintX = Paint()
      ..color = hCrossColor
      ..strokeWidth = hCrossWidth
      ..isAntiAlias = true;
    // k线图横线
    canvas.drawLine(
        Offset(-getCurrentOffset(size: size), y),
        Offset(-getCurrentOffset(size: size) + size.width / horizontalScale, y),
        paintX);
    if (horizontalScale >= 1) {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y), height: 2.0 * horizontalScale, width: 2.0),
          paintX);
    } else {
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y), height: 2.0, width: 2.0 / horizontalScale),
          paintX);
    }
  }

  TextPainter getTextPainter(text, color) {
    if (color == null) {
      color = const Color(0xff60738E);
    }
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color: color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  double getMainY(double y) =>
      indicators.first.render?.getVerticalPositionForPoint(value: y) ?? 50;
}
