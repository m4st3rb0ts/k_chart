//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:flutter/material.dart';

import '../../ticker/data_source.dart';
import '../indicator.dart';

import 'candle_entity_renderer.dart';

enum CandlesIndicators { MA, BOLL, NONE }

class CandlesIndicator extends Indicator {
  CandlesIndicator({
    required final DataSource dataSource,
    required final double height,
    required this.displayTimeLineChart,
    required this.candleIndicator,
    this.titlesTopPadding = 30.0,
    this.candleLineWidth = 1.5,
    this.candleItemWidth = 8.5,
    this.lineFillColor = const Color(0x554C86CD),
    this.gridColor = const Color(0xff4c5c74),
    this.kLineColor = const Color(0xff4C86CD),
    this.ma5Color = const Color(0xffC9B885),
    this.ma10Color = const Color(0xff6CB0A6),
    this.ma30Color = const Color(0xff9979C6),
    this.upColor = const Color(0xff4DAA90),
    this.dnColor = const Color(0xffC15466),
    this.nowPriceUpColor = const Color(0xff4DAA90),
    this.nowPriceDnColor = const Color(0xffC15466),
    this.nowPriceTextColor = const Color(0xffffffff),
    this.maxColor = const Color(0xffffffff),
    this.minColor = const Color(0xffffffff),
    this.nowPriceLineLength = 1,
    this.nowPriceLineSpan = 1,
  }) : super(dataSource: dataSource, height: height);

  final double titlesTopPadding;
  final double candleLineWidth;
  final double candleItemWidth;
  final Color lineFillColor;
  final Color gridColor;
  final Color kLineColor;
  final Color ma5Color;
  final Color ma10Color;
  final Color ma30Color;
  final Color upColor;
  final Color dnColor;
  final Color nowPriceUpColor;
  final Color nowPriceDnColor;
  final Color nowPriceTextColor;
  final Color maxColor;
  final Color minColor;
  final double nowPriceLineLength;
  final double nowPriceLineSpan;

  @override
  CandleEntityRender? get render => _render;
  CandleEntityRender? _render;

  final bool displayTimeLineChart;
  final CandlesIndicators candleIndicator;

  double _maxValue = double.minPositive;
  double _minValue = double.maxFinite;
  double _maxHighValue = double.minPositive;
  double _minLowValue = double.maxFinite;
  int _itemIndexWithMaxValue = 0;
  int _itemIndexWithMinValue = 0;

  double get currentMaxValue => _maxValue;
  double get currentMinValue => _minValue;
  double get currentMaxHighValue => _maxHighValue;
  double get currentMinLowValue => _minLowValue;
  int get currentItemIndexWithMaxValue => _itemIndexWithMaxValue;
  int get currentItemIndexWithMinValue => _itemIndexWithMinValue;

  void updateRender({
    required final Size size,
    required final double displayRectTop,
    required final double scale,
    required final int firstIndexToDisplay,
    required final int finalIndexToDisplay,
  }) {
    final normalizedStartIndex = max(0, firstIndexToDisplay);
    final normalizedStopIndex = min(data.length, finalIndexToDisplay);
    for (var i = normalizedStartIndex; i < normalizedStopIndex; i++) {
      final item = data[i];

      late double maxPrice;
      late double minPrice;
      if (candleIndicator == CandlesIndicators.MA) {
        maxPrice = max(
            item.high, _findMaxMA(maValueList: item.maValueList ?? <double>[]));
        minPrice = min(
            item.low, _findMinMA(maValueList: item.maValueList ?? <double>[]));
      } else if (candleIndicator == CandlesIndicators.BOLL) {
        maxPrice = max(item.top ?? -double.maxFinite, item.high);
        minPrice = min(item.bottom ?? double.maxFinite, item.low);
      } else {
        maxPrice = item.high;
        minPrice = item.low;
      }
      _maxValue = max(_maxValue, maxPrice);
      _minValue = min(_minValue, minPrice);

      if (_maxHighValue < item.high) {
        _maxHighValue = item.high;
        _itemIndexWithMaxValue = i;
      }
      if (_minLowValue > item.low) {
        _minLowValue = item.low;
        _itemIndexWithMinValue = i;
      }

      if (displayTimeLineChart == true) {
        _maxValue = max(_maxValue, item.close);
        _minValue = min(_minValue, item.close);
      }
    }

    _render = CandleEntityRender(
      displayRect: Rect.fromLTWH(
        0,
        displayRectTop,
        size.width,
        height + displayRectTop,
      ),
      titlesTopPadding: titlesTopPadding,
      maxVerticalValue: _maxValue,
      minVerticalValue: _minValue,
      indicator: candleIndicator,
      isTimeLineMode: displayTimeLineChart,
      fixedDecimalsLength: dataSource.fixedDecimalsLength,
      timelineHorizontalScale: scale,
      maFactorsForTitles: dataSource.maDayList,
      candleItemWidth: candleItemWidth,
      candleLineWidth: candleLineWidth,
      dnColor: dnColor,
      gridColor: gridColor,
      kLineColor: kLineColor,
      lineFillColor: lineFillColor,
      ma5Color: ma5Color,
      ma10Color: ma10Color,
      ma30Color: ma30Color,
      upColor: upColor,
      maxColor: maxColor,
      minColor: minColor,
      nowPriceDnColor: nowPriceDnColor,
      nowPriceLineLength: nowPriceLineLength,
      nowPriceLineSpan: nowPriceLineSpan,
      nowPriceTextColor: nowPriceTextColor,
      nowPriceUpColor: nowPriceUpColor,
    );
  }

  double _findMaxMA({required final List<double> maValueList}) {
    var result = double.minPositive;
    for (final maValue in maValueList) {
      result = max(result, maValue);
    }
    return result;
  }

  // [] Reviewed
  double _findMinMA({required final List<double> maValueList}) {
    var result = double.maxFinite;
    for (final maValue in maValueList) {
      result = min(result, maValue == 0 ? double.maxFinite : maValue);
    }
    return result;
  }
}
