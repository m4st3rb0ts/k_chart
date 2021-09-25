//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:k_chart/chart_style.dart';
import 'package:k_chart/entity/k_line_entity.dart';

import 'dart:ui';

import '../indicator.dart';
import 'macd.dart';
import 'macd_renderer.dart';

class MacdIndicator extends Indicator<Macd> {
  MacdIndicator({
    required final List<KLineEntity> dataSource,
    required this.indicator,
    required final double height,
    required this.chartStyle,
  }) : super(dataSource: dataSource, height: height) {
    for (var i = 0; i < dataSource.length; i++) {
      final dataItem = dataSource[i];
      var macd = Macd(
        (c) => c
          ..k = dataItem.k ?? 0
          ..d = dataItem.d ?? 0
          ..j = dataItem.j ?? 0
          ..rsi = dataItem.rsi ?? 0
          ..r = dataItem.r ?? 0
          ..cci = dataItem.cci ?? 0
          ..macd = dataItem.macd ?? 0
          ..dif = dataItem.dif ?? 0
          ..dea = dataItem.dea ?? 0,
      );
      _macd.add(macd);
    }
  }

  @override
  BuiltList<Macd> get data => _macd.toBuiltList();
  List<Macd> _macd = <Macd>[];

  final MacdIndicators indicator;
  final ChartStyle chartStyle;

  @override
  MacdRenderer? get render => _render;
  MacdRenderer? _render;

  @override
  void updateRender({
    required final Size size,
    required final double displayRectTop,
    required final double scale,
    required final int firstIndexToDisplay,
    required final int finalIndexToDisplay,
  }) {
    var maxValue = double.minPositive;
    var minValue = double.maxFinite;
    var fixedDecimalsLength = 2;

    final normalizedStartIndex = max(0, firstIndexToDisplay);
    final normalizedStopIndex = min(data.length, finalIndexToDisplay);
    for (var i = normalizedStartIndex; i < normalizedStopIndex; i++) {
      final item = data[i];
      if (indicator == MacdIndicators.MACD) {
        maxValue = max(maxValue, max(item.macd, max(item.dif, item.dea)));
        minValue = min(minValue, min(item.macd, min(item.dif, item.dea)));
      } else if (indicator == MacdIndicators.KDJ) {
        maxValue = max(maxValue, max(item.k, max(item.d, item.j)));
        minValue = min(minValue, min(item.k, min(item.d, item.j)));
      } else if (indicator == MacdIndicators.RSI) {
        maxValue = max(maxValue, item.rsi);
        minValue = min(minValue, item.rsi);
      } else if (indicator == MacdIndicators.WR) {
        maxValue = 0;
        minValue = -100;
      } else if (indicator == MacdIndicators.CCI) {
        maxValue = max(maxValue, item.cci);
        minValue = min(minValue, item.cci);
      } else {
        maxValue = 0;
        minValue = 0;
      }
    }

    _render = MacdRenderer(
      displayRect: Rect.fromLTWH(
        0,
        displayRectTop,
        size.width,
        height,
      ),
      titleTopPadding: chartStyle.childPadding,
      indicator: indicator,
      maxVerticalValue: maxValue,
      minVerticalValue: minValue,
      fixedDecimalsLength: fixedDecimalsLength,
      chartStyle: chartStyle,
    );
  }
}
