//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:k_chart/chart_style.dart';

import 'package:k_chart/utils/number_util.dart';

import 'candle.dart';
import '../indicator.dart';

import '../../entity/k_line_entity.dart';
import 'candle_entity_renderer.dart';

enum CandlesIndicators { MA, BOLL, NONE }

class CandlesIndicator extends Indicator<Candle> {
  CandlesIndicator({
    required final List<KLineEntity> dataSource,
    required final this.height,
    required this.displayTimeLineChart,
    required this.candleIndicator,
    this.maDayList = const [5, 10, 20],
  }) : super(dataSource: dataSource) {
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
      _candles = _candles.rebuild((c) => c.add(candle));
    }
    _calcMA();
    _calcBOLL();
  }

  BuiltList<Candle> _candles = BuiltList<Candle>();
  BuiltList<Candle> get data => _candles;

  CandleEntityRender? _render;
  CandleEntityRender? get render => _render;

  final double height;

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
    required final double scale,
    required final int startIndex,
    required final int stopIndex,
  }) {
    final normalizedStartIndex = max(0, startIndex);
    final normalizedStopIndex = min(data.length, stopIndex);
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
      displayRect: Rect.fromLTRB(
        0,
        ChartStyle().topPadding,
        size.width,
        ChartStyle().topPadding + height,
      ),
      maxVerticalValue: _maxValue,
      minVerticalValue: _minValue,
      indicator: candleIndicator,
      isTimeLineMode: displayTimeLineChart,
      fixedDecimalsLength: _fixedDecimalsLength,
      chartStyle: ChartStyle(),
      timelineHorizontalScale: scale,
      maFactorsForTitles: maDayList,
    );
  }

  double _findMaxMA({required final BuiltList<double> maValueList}) {
    double result = double.minPositive;
    for (final maValue in maValueList) {
      result = max(result, maValue);
    }
    return result;
  }

  // [] Reviewed
  double _findMinMA({required final BuiltList<double> maValueList}) {
    double result = double.maxFinite;
    for (final maValue in maValueList) {
      result = min(result, maValue == 0 ? double.maxFinite : maValue);
    }
    return result;
  }

  void _calcMA() {
    List<double> ma = List<double>.filled(maDayList.length, 0);
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        final entity = data[i];
        final closePrice = entity.close;
        var maValueList = List<double>.filled(maDayList.length, 0);
        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            maValueList[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= data[i - maDayList[j]].close;
            maValueList[j] = ma[j] / maDayList[j];
          } else {
            maValueList[j] = 0;
          }
        }
        _candles.rebuild(
          (c) => c[i].maValueList.rebuild(
                (mal) => mal.addAll(maValueList),
              ),
        );
      }
    }
  }

  void _calcBOLL() {
    final n = 20;
    final k = 2;
    _calcBOLLMA(n);
    for (int i = 0; i < data.length; i++) {
      final entity = data[i];
      if (i >= n) {
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = data[j].close;
          double m = entity.bollMa;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        _candles.rebuild(
          (c) => c
            ..[i] = c[i].rebuild(
              (item) => item
                ..middle = entity.bollMa
                ..top = entity.bollMa + k * md
                ..bottom = entity.bollMa - k * md,
            ),
        );
      }
    }
  }

  void _calcBOLLMA(final int day) {
    double ma = 0;
    for (int i = 0; i < data.length; i++) {
      final entity = data[i];
      ma += entity.close;
      if (i == day - 1) {
        _candles.rebuild(
          (c) => c
            ..[i] = c[i].rebuild(
              (item) => item..bollMa = ma / day,
            ),
        );
      } else if (i >= day) {
        ma -= data[i - day].close;
        _candles.rebuild(
          (c) => c
            ..[i] = c[i].rebuild(
              (item) => item..bollMa = ma / day,
            ),
        );
      } else {
        _candles.rebuild(
          (c) => c
            ..[i] = c[i].rebuild(
              (item) => item..bollMa = 0,
            ),
        );
      }
    }
  }
}
