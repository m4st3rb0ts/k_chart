//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:k_chart/chart_style.dart';

import 'package:k_chart/renders/base_chart_renderer.dart';

import 'candle.dart';
import '../indicator.dart';

import '../../entity/k_line_entity.dart';
import 'candle_entity_renderer.dart';

enum CandlesIndicators { MA, BOLL, NONE }

class CandlesIndicator extends Indicator {
  CandlesIndicator({
    required final List<KLineEntity> dataSource,
    required this.displayTimeLineChart,
    required this.candleIndicator,
  }) : super(dataSource: dataSource) {
    for (var i = 0; i < dataSource.length; i++) {
      final dataItem = dataSource[i];
      final candle = Candle(
        (c) => c
          ..open = dataItem.open
          ..close = dataItem.close
          ..high = dataItem.high
          ..low = dataItem.low
          ..top = null
          ..middle = null
          ..bottom = null
          ..maValueList = BuiltList<double>().toBuilder(),
      );
      _candles = _candles.rebuild((c) => c.add(candle));
    }
  }

  BaseChartRenderer generateRender({
    required final Size size,
  }) {
    return CandleEntityRender(
      displayRect: null,
      maxVerticalValue: null,
      minVerticalValue: null,
      indicator: candleIndicator,
      isTimeLineMode: displayTimeLineChart,
      fixedDecimalsLength: 2,
      chartStyle: ChartStyle(),
      timelineHorizontalScale: null,
    );
  }

  BuiltList<Candle> _candles = BuiltList<Candle>();
  BuiltList<Candle> get candles => _candles;

  final bool displayTimeLineChart;
  final CandlesIndicators candleIndicator;

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

  void getMainMaxMinValue() {
    double maxValue = double.minPositive;
    double minValue = double.maxFinite;
    double maxHighValue = double.minPositive;
    double minLowValue = double.maxFinite;
    int mMainMaxIndex = 0;
    int mMainMinIndex = 0;

    for (var i = 0; i < candles.length; i++) {
      final item = candles[i];
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
      maxValue = max(maxValue, maxPrice);
      minValue = min(minValue, minPrice);

      if (maxHighValue < item.high) {
        maxHighValue = item.high;
        mMainMaxIndex = i;
      }
      if (minLowValue > item.low) {
        minLowValue = item.low;
        mMainMinIndex = i;
      }

      if (displayTimeLineChart == true) {
        maxValue = max(maxValue, item.close);
        minValue = min(minValue, item.close);
      }
    }
  }
}
