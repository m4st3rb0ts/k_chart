//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../entity/k_line_entity.dart';
import '../../utils/number_util.dart';

import '../indicator.dart';
import 'candle.dart';
import 'candle_entity_renderer.dart';

enum CandlesIndicators { MA, BOLL, NONE }

class CandlesIndicator extends Indicator<Candle> {
  CandlesIndicator({
    required final List<KLineEntity> dataSource,
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
    this.maDayList = const [5, 10, 20],
  }) : super(dataSource: dataSource, height: height) {
    for (var i = 0; i < dataSource.length; i++) {
      final dataItem = dataSource[i];
      var candle = Candle(
        (c) => c
          ..open = dataItem.open
          ..close = dataItem.close
          ..high = dataItem.high
          ..low = dataItem.low
          ..top = dataItem.top ?? 0
          ..middle = dataItem.middle ?? 0
          ..bottom = dataItem.bottom ?? 0
          ..bollMa = dataItem.BOLLMA ?? 0
          ..maValueList = (dataItem.maValueList?.toList() ?? <double>[])
              .toBuiltList()
              .toBuilder(),
      );
      _candles.add(candle);
    }
  }

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

  List<Candle> _candles = <Candle>[];
  @override
  BuiltList<Candle> get data => _candles.toBuiltList();

  @override
  CandleEntityRender? get render => _render;

  final bool displayTimeLineChart;
  final CandlesIndicators candleIndicator;
  final List<int> maDayList;

  double _maxValue = double.minPositive;
  double _minValue = double.maxFinite;
  double _maxHighValue = double.minPositive;
  double _minLowValue = double.maxFinite;
  int _itemIndexWithMaxValue = 0;
  int _itemIndexWithMinValue = 0;
  int _fixedDecimalsLength = 2;

  double get currentMaxValue => _maxValue;
  double get currentMinValue => _minValue;
  double get currentMaxHighValue => _maxHighValue;
  double get currentMinLowValue => _minLowValue;
  int get currentItemIndexWithMaxValue => _itemIndexWithMaxValue;
  int get currentItemIndexWithMinValue => _itemIndexWithMinValue;
  int get currentFixedDecimalsLength => _fixedDecimalsLength;

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
      _fixedDecimalsLength = max(
        NumberUtil.getMaxDecimalLength(
          item.open,
          item.close,
          item.high,
          item.low,
        ),
        _fixedDecimalsLength,
      );

      late double maxPrice;
      late double minPrice;
      if (candleIndicator == CandlesIndicators.MA) {
        maxPrice = max(item.high, _findMaxMA(maValueList: item.maValueList));
        minPrice = min(item.low, _findMinMA(maValueList: item.maValueList));
      } else if (candleIndicator == CandlesIndicators.BOLL) {
        maxPrice = max(item.top, item.high);
        minPrice = min(item.bottom, item.low);
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
      fixedDecimalsLength: _fixedDecimalsLength,
      timelineHorizontalScale: scale,
      maFactorsForTitles: maDayList,
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

  double _findMaxMA({required final BuiltList<double> maValueList}) {
    var result = double.minPositive;
    for (final maValue in maValueList) {
      result = max(result, maValue);
    }
    return result;
  }

  // [] Reviewed
  double _findMinMA({required final BuiltList<double> maValueList}) {
    var result = double.maxFinite;
    for (final maValue in maValueList) {
      result = min(result, maValue == 0 ? double.maxFinite : maValue);
    }
    return result;
  }
}
