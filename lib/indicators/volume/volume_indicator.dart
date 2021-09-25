//
// Created by @sh1l0n
//

import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:k_chart/chart_style.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:k_chart/utils/number_util.dart';

import 'dart:ui';

import '../indicator.dart';
import 'volume.dart';
import 'volume_renderer.dart';

class VolumeIndicator extends Indicator<Volume> {
  VolumeIndicator({
    required final List<KLineEntity> dataSource,
    required final double height,
    required this.chartStyle,
  }) : super(dataSource: dataSource, height: height) {
    for (var i = 0; i < dataSource.length; i++) {
      final dataItem = dataSource[i];
      var candle = Volume(
        (c) => c
          ..open = dataItem.open
          ..close = dataItem.close
          ..vol = dataItem.vol
          ..ma5Volume = dataItem.MA5Volume ?? 0
          ..ma10Volume = dataItem.MA10Volume ?? 0,
      );
      _volumes.add(candle);
    }
  }

  @override
  BuiltList<Volume> get data => _volumes.toBuiltList();
  List<Volume> _volumes = <Volume>[];

  @override
  VolumeRenderer? get render => _render;
  VolumeRenderer? _render;

  final ChartStyle chartStyle;

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
    for (int i = normalizedStartIndex; i <= normalizedStopIndex; i++) {
      final item = data[i];

      fixedDecimalsLength = max(
        NumberUtil.getMaxDecimalLength(
          item.open,
          item.close,
          0,
          0,
        ),
        fixedDecimalsLength,
      );

      maxValue =
          max(maxValue, max(item.vol, max(item.ma5Volume, item.ma10Volume)));
      minValue =
          min(minValue, min(item.vol, min(item.ma5Volume, item.ma10Volume)));
    }

    _render = VolumeRenderer(
      displayRect: Rect.fromLTWH(
        0,
        displayRectTop,
        size.width,
        height,
      ),
      titlesTopPadding: chartStyle.childPadding,
      maxVerticalValue: maxValue,
      minVerticalValue: minValue,
      fixedDecimalsLength: fixedDecimalsLength,
      chartStyle: chartStyle,
    );
  }
}
