//
// Created by @sh1l0n
//

import 'dart:math';
import 'dart:ui';

import 'package:built_collection/built_collection.dart';

import '../../entity/k_line_entity.dart';
import '../indicator.dart';
import 'macd.dart';
import 'macd_renderer.dart';

class MacdIndicator extends Indicator<Macd> {
  MacdIndicator({
    required final List<KLineEntity> dataSource,
    required this.indicator,
    required final double height,
    this.macdDisplayItemWidth = 3.0,
    this.titlesTopPadding = 12,
    this.defaultTextColor = const Color(0xff60738E),
    this.macdColor = const Color(0xff4729AE),
    this.difColor = const Color(0xffC9B885),
    this.deaColor = const Color(0xff6CB0A6),
    this.kColor = const Color(0xffC9B885),
    this.dColor = const Color(0xff6CB0A6),
    this.jColor = const Color(0xff9979C6),
    this.rsiColor = const Color(0xffC9B885),
    this.upColor = const Color(0xff4DAA90),
    this.dnColor = const Color(0xffC15466),
    this.gridColor = const Color(0xff4c5c74),
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

  @override
  MacdRenderer? get render => _render;
  MacdRenderer? _render;

  final double titlesTopPadding;
  final double macdDisplayItemWidth;
  final Color defaultTextColor;
  final Color macdColor;
  final Color difColor;
  final Color deaColor;
  final Color kColor;
  final Color dColor;
  final Color jColor;
  final Color rsiColor;
  final Color upColor;
  final Color dnColor;
  final Color gridColor;

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
      macdDisplayItemWidth: macdDisplayItemWidth,
      titlesTopPadding: titlesTopPadding,
      indicator: indicator,
      maxVerticalValue: maxValue,
      minVerticalValue: minValue,
      fixedDecimalsLength: fixedDecimalsLength,
      defaultTextColor: defaultTextColor,
      macdColor: macdColor,
      dColor: dColor,
      deaColor: deaColor,
      difColor: difColor,
      jColor: jColor,
      kColor: kColor,
      rsiColor: rsiColor,
      upColor: upColor,
      dnColor: dnColor,
      gridColor: gridColor,
    );
  }
}
