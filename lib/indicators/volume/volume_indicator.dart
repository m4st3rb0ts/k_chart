//
// Created by @sh1l0n
//
import 'dart:ui';
import 'dart:math';

import '../../ticker/data_source.dart';
import '../../common.dart';
import '../indicator.dart';

import 'volume_renderer.dart';

class VolumeIndicator extends Indicator {
  VolumeIndicator({
    required final DataSource dataSource,
    required final double height,
    this.titlesTopPadding = 12,
    this.volumeItemWidth = 8.5,
    this.ma10Color = const Color(0xff6CB0A6),
    this.ma5Color = const Color(0xffC9B885),
    this.volColor = const Color(0xff4729AE),
    this.gridColor = const Color(0xff4c5c74),
    this.upColor = const Color(0xff4DAA90),
    this.dnColor = const Color(0xffC15466),
  }) : super(dataSource: dataSource, height: height);

  @override
  VolumeRenderer? get render => _render;
  VolumeRenderer? _render;

  final double titlesTopPadding;
  final double volumeItemWidth;
  final Color ma10Color;
  final Color ma5Color;
  final Color volColor;
  final Color dnColor;
  final Color upColor;
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

    final normalizedStartIndex = max(0, firstIndexToDisplay);
    final normalizedStopIndex = min(data.length, finalIndexToDisplay);
    for (int i = normalizedStartIndex; i <= normalizedStopIndex; i++) {
      final item = data[i];
      maxValue = max(
        maxValue,
        max(
          item.vol,
          max(
            item.ma5Volume ?? -double.maxFinite,
            item.ma10Volume ?? -double.maxFinite,
          ),
        ),
      );
      minValue = min(
        minValue,
        min(
          item.vol,
          min(
            item.ma5Volume ?? double.maxFinite,
            item.ma10Volume ?? double.maxFinite,
          ),
        ),
      );
    }

    _render = VolumeRenderer(
      displayRect: Rect.fromLTWH(
        0,
        displayRectTop,
        size.width,
        height,
      ),
      titlesTopPadding: titlesTopPadding,
      maxVerticalValue: maxValue,
      minVerticalValue: minValue,
      fixedDecimalsLength: dataSource.fixedDecimalsLength,
      volumeItemWidth: volumeItemWidth,
      dnColor: dnColor,
      gridColor: gridColor,
      ma10Color: ma10Color,
      ma5Color: ma5Color,
      upColor: upColor,
      volColor: volColor,
    );
  }
}
