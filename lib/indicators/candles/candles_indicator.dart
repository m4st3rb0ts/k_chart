//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../../chart_style.dart';
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
    required this.chartStyle,
    this.maDayList = const [5, 10, 20],
  }) : super(dataSource: dataSource, height: height) {
    for (var i = 0; i < dataSource.length; i++) {
      final dataItem = dataSource[i];
      var candle = Candle((c) => c
        ..open = dataItem.open
        ..close = dataItem.close
        ..high = dataItem.high
        ..low = dataItem.low
        ..top = 0
        ..middle = 0
        ..bottom = 0
        ..bollMa = 0
        ..maValueList = BuiltList<double>().toBuilder());
      _candles.add(candle);
    }
    _calcMA();
    _calcBOLL();
  }

  List<Candle> _candles = <Candle>[];
  BuiltList<Candle> get data => _candles.toBuiltList();

  CandleEntityRender? _render;
  CandleEntityRender? get render => _render;
  final ChartStyle chartStyle;

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
        height,
      ),
      maxVerticalValue: _maxValue,
      minVerticalValue: _minValue,
      indicator: candleIndicator,
      isTimeLineMode: displayTimeLineChart,
      fixedDecimalsLength: _fixedDecimalsLength,
      chartStyle: chartStyle,
      timelineHorizontalScale: scale,
      maFactorsForTitles: maDayList,
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

  void _calcMA() {
    var ma = List<double>.filled(maDayList.length, 0);
    if (data.isNotEmpty) {
      for (var i = 0; i < data.length; i++) {
        var maValueList = List<double>.filled(maDayList.length, 0);
        for (var j = 0; j < maDayList.length; j++) {
          ma[j] += data[i].close;
          if (i == maDayList[j] - 1) {
            maValueList[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= data[i - maDayList[j]].close;
            maValueList[j] = ma[j] / maDayList[j];
          } else {
            maValueList[j] = 0;
          }
        }
        _candles[i] = _candles[i].rebuild(
          (c) => c
            ..maValueList =
                c.maValueList = maValueList.toBuiltList().toBuilder(),
        );
      }
    }
  }

  void _calcBOLL() {
    final n = 20;
    final k = 2;
    _calcBOLLMA(n);
    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      if (i >= n) {
        var md = 0.0;
        for (var j = i - n + 1; j <= i; j++) {
          final c = data[j].close;
          final m = entity.bollMa;
          final value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        _candles[i] = _candles[i].rebuild(
          (c) => c
            ..middle = entity.bollMa
            ..top = entity.bollMa + k * md
            ..bottom = entity.bollMa - k * md,
        );
      }
    }
  }

  void _calcBOLLMA(final int day) {
    var ma = 0.0;
    for (var i = 0; i < data.length; i++) {
      ma += data[i].close;
      if (i == day - 1) {
        _candles[i] = _candles[i].rebuild(
          (c) => c..bollMa = ma / day,
        );
      } else if (i >= day) {
        ma -= data[i - day].close;
        _candles[i] = _candles[i].rebuild(
          (c) => c..bollMa = ma / day,
        );
      }
    }
  }
}
