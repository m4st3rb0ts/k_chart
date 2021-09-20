import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';
import 'package:k_chart/indicators/candles/candle.dart';
import 'package:k_chart/indicators/candles/candles_indicator.dart';
import 'package:k_chart/utils/number_util.dart';

import '../entity/info_window_entity.dart';
import '../entity/k_line_entity.dart';
import '../flutter_k_chart.dart';
import '../utils/date_format_util.dart';
import 'base_chart_painter.dart';
import '../renders/base_chart_renderer.dart';
import '../renders/macd_entity_renderer.dart';
import '../renders/volume_renderer.dart';

class ChartPainter extends BaseChartPainter {
  ChartPainter({
    required this.candlesIndicator,
    required final ChartStyle chartStyle,
    required final List<KLineEntity> dataSource,
    required final double horizontalScale,
    required final double currentHorizontalScroll,
    required final bool shouldDisplaySelection,
    required final double selectedHorizontalValue,
    required this.hideVolumeChart,
    required final SecondaryIndicator secondaryIndicator,
    this.sink,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.bgColor,
    this.fixedLength = 2,
  })  : assert(bgColor == null || bgColor.length >= 2),
        super(
          chartStyle: chartStyle,
          dataSource: dataSource,
          horizontalScale: horizontalScale,
          currentHorizontalScroll: currentHorizontalScroll,
          shouldDisplaySelection: shouldDisplaySelection,
          selectedHorizontalValue: selectedHorizontalValue,
          secondaryIndicator: secondaryIndicator,
        ) {
    selectPointPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..color = chartStyle.colors.selectFillColor;
    selectorBorderPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..color = chartStyle.colors.selectBorderColor;
    nowPricePaint = Paint()
      ..strokeWidth = chartStyle.nowPriceLineWidth
      ..isAntiAlias = true;
  }

  /// Should display volume?
  final bool hideVolumeChart;

  final CandlesIndicator candlesIndicator;
  BaseChartRenderer? mVolRenderer;
  BaseChartRenderer? mSecondaryRenderer;
  StreamSink<InfoWindowEntity?>? sink;
  Color? upColor, dnColor;
  Color? ma5Color, ma10Color, ma30Color;
  Color? volColor;
  Color? macdColor, difColor, deaColor, jColor;
  List<Color>? bgColor;
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
    final volumeGraphHeight =
        !hideVolumeChart ? candlesIndicator.height * 0.2 : 0;
    final secondaryGraphHeight = secondaryIndicator != SecondaryIndicator.NONE
        ? candlesIndicator.height * 0.2
        : 0;
    candlesIndicator.updateRender(
      size: size,
      scale: horizontalScale,
      firstIndexToDisplay: mStartIndex,
      finalIndexToDisplay: mStopIndex,
    );
    if (!hideVolumeChart) {
      mVolRenderer = VolumeRenderer(
        displayRect: Rect.fromLTRB(
          0,
          candlesIndicator.render?.displayRect.bottom ??
              0 + chartStyle.childPadding,
          size.width,
          (candlesIndicator.render?.displayRect.bottom ?? 0) +
              volumeGraphHeight,
        ),
        maxVerticalValue: mVolMaxValue,
        minVerticalValue: mVolMinValue,
        fixedDecimalsLength: fixedLength,
        chartStyle: chartStyle,
      );
    }
    if (secondaryIndicator != SecondaryIndicator.NONE) {
      mSecondaryRenderer = MACDEntityRenderer(
        displayRect: Rect.fromLTRB(
          0,
          candlesIndicator.render?.displayRect.bottom ??
              0 + volumeGraphHeight + chartStyle.childPadding,
          size.width,
          (candlesIndicator.render?.displayRect.bottom ?? 0) +
              volumeGraphHeight +
              secondaryGraphHeight,
        ),
        maxVerticalValue: mSecondaryMaxValue,
        minVerticalValue: mSecondaryMinValue,
        indicator: secondaryIndicator,
        fixedDecimalsLength: fixedLength,
        chartStyle: chartStyle,
      );
    }
  }

  @override
  void drawBackground(
      {required final Canvas canvas, required final Size size}) {
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: bgColor ?? chartStyle.colors.bgColor,
    );
    final mainRect = Rect.fromLTRB(
      0,
      0,
      candlesIndicator.render?.displayRect.width ?? 0,
      candlesIndicator.render?.displayRect.height ?? 0 + chartStyle.topPadding,
    );
    canvas.drawRect(
        mainRect, mBgPaint..shader = mBgGradient.createShader(mainRect));

    if (mVolRenderer != null) {
      Rect volRect = Rect.fromLTRB(
        0,
        mVolRenderer?.displayRect.top ?? 0 - chartStyle.childPadding,
        mVolRenderer?.displayRect.width ?? 0,
        mVolRenderer?.displayRect.bottom ?? 0,
      );
      canvas.drawRect(
          volRect, mBgPaint..shader = mBgGradient.createShader(volRect));
    }

    if (mSecondaryRenderer != null) {
      Rect secondaryRect = Rect.fromLTRB(
        0,
        mSecondaryRenderer?.displayRect.top ?? 0 - chartStyle.childPadding,
        mSecondaryRenderer?.displayRect.width ?? 0,
        mSecondaryRenderer?.displayRect.bottom ?? 0,
      );
      canvas.drawRect(secondaryRect,
          mBgPaint..shader = mBgGradient.createShader(secondaryRect));
    }
    Rect dateRect = Rect.fromLTRB(
        0, size.height - chartStyle.bottomPadding, size.width, size.height);
    canvas.drawRect(
        dateRect, mBgPaint..shader = mBgGradient.createShader(dateRect));
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final Size size,
  }) {
    if (!hideGrid) {
      candlesIndicator.render?.drawGrid(canvas: canvas);
      mVolRenderer?.drawGrid(canvas: canvas);
      mSecondaryRenderer?.drawGrid(canvas: canvas);
    }
  }

  @override
  void drawChart({required final Canvas canvas, required final Size size}) {
    canvas.save();
    canvas.translate(getCurrentOffset(size: size) * horizontalScale, 0.0);
    canvas.scale(horizontalScale, 1.0);
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      final curPoint = dataSource[i];
      KLineEntity lastPoint = i == 0 ? curPoint : dataSource[i - 1];
      double curX = getLeftOffsetByIndex(index: i);
      double lastX = i == 0 ? curX : getLeftOffsetByIndex(index: i - 1);

      final curCandle = candlesIndicator.data[i];
      final lastCandle = i == 0 ? curCandle : candlesIndicator.data[i - 1];
      candlesIndicator.render?.drawChart(
        lastValue: RenderData<Candle>(data: lastCandle, x: lastX),
        currentValue: RenderData<Candle>(data: curCandle, x: curX),
        size: size,
        canvas: canvas,
      );

      mVolRenderer?.drawChart(
        lastValue: RenderData<VolumeEntity>(data: lastPoint, x: lastX),
        currentValue: RenderData<VolumeEntity>(data: curPoint, x: curX),
        size: size,
        canvas: canvas,
      );
      mSecondaryRenderer?.drawChart(
        lastValue: RenderData<MACDEntity>(data: lastPoint, x: lastX),
        currentValue: RenderData<MACDEntity>(data: curPoint, x: curX),
        size: size,
        canvas: canvas,
      );
    }

    canvas.restore();
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final Size size,
  }) {
    var textStyle = getTextStyle(color: chartStyle.colors.defaultTextColor);
    if (!hideGrid) {
      candlesIndicator.render
          ?.drawRightText(canvas: canvas, textStyle: textStyle);
    }
    mVolRenderer?.drawRightText(canvas: canvas, textStyle: textStyle);
    mSecondaryRenderer?.drawRightText(canvas: canvas, textStyle: textStyle);
  }

  @override
  void drawDate({required final Canvas canvas, required final Size size}) {
    double columnSpace = size.width / chartStyle.numberOfGridColumns;
    double startX =
        getLeftOffsetByIndex(index: mStartIndex) - chartStyle.pointWidth * 0.5;
    double stopX =
        getLeftOffsetByIndex(index: mStopIndex) + chartStyle.pointWidth * 0.5;
    double x = 0.0;
    double y = 0.0;
    for (var i = 0; i <= chartStyle.numberOfGridColumns; ++i) {
      double translateX =
          translateToCurrentViewport(leftOffset: columnSpace * i, size: size);

      if (translateX >= startX && translateX <= stopX) {
        int index = dataIndexInViewportFor(leftOffset: translateX);

        final item = getDataItemByIndex(index: index);
        if (item == null) {
          return;
        }
        TextPainter tp = getTextPainter(getDate(item.time), null);
        y = size.height -
            (chartStyle.bottomPadding - tp.height) / 2 -
            tp.height;
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
    KLineEntity? point = getDataItemByIndex(index: index);
    if (point == null) {
      return;
    }

    TextPainter tp =
        getTextPainter(point.close, chartStyle.colors.crossTextColor);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;
    if (translateXtoX(
            translateX: getLeftOffsetByIndex(index: index), size: size) <
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

    TextPainter dateTp =
        getTextPainter(getDate(point.time), chartStyle.colors.crossTextColor);
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(
        translateX: getLeftOffsetByIndex(index: index), size: size);
    y = size.height - chartStyle.bottomPadding;

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
    required final KLineEntity data,
    required final double x,
  }) {
    //长按显示按中的数据
    KLineEntity? customData = data;
    var index = 0;
    if (shouldDisplaySelection) {
      index = getIndexForSelectedHorizontalValue(size: size);
      customData = getDataItemByIndex(index: index);
      if (customData == null) {
        //TODO: Review if return or assign to data
        return;
      }
    } else {
      index = dataIndexInViewportFor(leftOffset: currentHorizontalScroll);
    }
    //松开显示最后一条数据
    candlesIndicator.render?.drawText(
        canvas: canvas, value: candlesIndicator.data[index], leftOffset: x);
    mVolRenderer?.drawText(canvas: canvas, value: customData, leftOffset: x);
    mSecondaryRenderer?.drawText(
        canvas: canvas, value: customData, leftOffset: x);
  }

  @override
  void drawMaxAndMin({required final Canvas canvas, required final Size size}) {
    if (candlesIndicator.render?.isTimeLineMode ?? false) {
      return;
    }
    //绘制最大值和最小值
    double x = translateXtoX(
        translateX: getLeftOffsetByIndex(
            index: candlesIndicator.currentItemIndexWithMinValue),
        size: size);
    double y = getMainY(candlesIndicator.currentMinLowValue);
    if (x < size.width / 2) {
      //画右边
      TextPainter tp = getTextPainter(
          "── " +
              candlesIndicator.currentMinLowValue.toStringAsFixed(fixedLength),
          chartStyle.colors.minColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter(
          candlesIndicator.currentMinLowValue.toStringAsFixed(fixedLength) +
              " ──",
          chartStyle.colors.minColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
    x = translateXtoX(
        translateX: getLeftOffsetByIndex(
            index: candlesIndicator.currentItemIndexWithMaxValue),
        size: size);
    y = getMainY(candlesIndicator.currentMaxHighValue);
    if (x < size.width / 2) {
      //画右边
      TextPainter tp = getTextPainter(
          "── " +
              candlesIndicator.currentMaxHighValue.toStringAsFixed(fixedLength),
          chartStyle.colors.maxColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter(
          candlesIndicator.currentMaxHighValue.toStringAsFixed(fixedLength) +
              " ──",
          chartStyle.colors.maxColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  @override
  void drawNowPrice({required final Canvas canvas, required final Size size}) {
    if (!showNowPrice) {
      return;
    }

    if (dataSource.isEmpty) {
      return;
    }

    double value = dataSource.last.close;
    double y = getMainY(value);
    //不在视图展示区域不绘制
    if (y > getMainY(candlesIndicator.currentMinLowValue) ||
        y < getMainY(candlesIndicator.currentMaxHighValue)) {
      return;
    }
    nowPricePaint
      ..color = value >= dataSource.last.open
          ? chartStyle.colors.nowPriceUpColor
          : chartStyle.colors.nowPriceDnColor;
    //先画横线
    double startX = 0;
    final max = -getCurrentOffset(size: size) + size.width / horizontalScale;
    final space = chartStyle.nowPriceLineSpan + chartStyle.nowPriceLineLength;
    while (startX < max) {
      canvas.drawLine(Offset(startX, y),
          Offset(startX + chartStyle.nowPriceLineLength, y), nowPricePaint);
      startX += space;
    }
    //再画背景和文本
    TextPainter tp = getTextPainter(value.toStringAsFixed(fixedLength),
        chartStyle.colors.nowPriceTextColor);
    double left = 0;
    double top = y - tp.height / 2;
    canvas.drawRect(Rect.fromLTRB(left, top, left + tp.width, top + tp.height),
        nowPricePaint);
    tp.paint(canvas, Offset(0, top));
  }

  ///画交叉线
  void drawCrossLine({required final Canvas canvas, required final Size size}) {
    var index = getIndexForSelectedHorizontalValue(size: size);
    final point = getDataItemByIndex(index: index);
    if (point == null) {
      return;
    }
    Paint paintY = Paint()
      ..color = chartStyle.colors.vCrossColor
      ..strokeWidth = chartStyle.vCrossWidth
      ..isAntiAlias = true;
    double x = getLeftOffsetByIndex(index: index);
    double y = getMainY(point.close);
    // k线图竖线
    canvas.drawLine(Offset(x, chartStyle.topPadding),
        Offset(x, size.height - chartStyle.bottomPadding), paintY);

    Paint paintX = Paint()
      ..color = chartStyle.colors.hCrossColor
      ..strokeWidth = chartStyle.hCrossWidth
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
      color = chartStyle.colors.defaultTextColor;
    }
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color: color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(int? date) => dateFormat(
      DateTime.fromMillisecondsSinceEpoch(
          date ?? DateTime.now().millisecondsSinceEpoch),
      displayDateFormats);

  double getMainY(double y) =>
      candlesIndicator.render?.getVerticalPositionForPoint(value: y) ?? 50;

  /// 点是否在SecondaryRect中
  bool isInSecondaryRect(Offset point) {
    return mSecondaryRenderer?.displayRect.contains(point) ?? false;
  }
}
