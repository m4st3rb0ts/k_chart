//
// Created by @sh1l0n
//

import 'package:flutter/material.dart';

import 'package:built_collection/built_collection.dart';

import '../ticker/ticker.dart';
import '../ticker/data_source.dart';

import 'indicator_renderer.dart';

abstract class Indicator {
  const Indicator({
    required this.dataSource,
    required this.height,
  });

  final DataSource dataSource;
  void updateRender({
    required final Size size,
    required final double displayRectTop,
    required final double scale,
    required final int firstIndexToDisplay,
    required final int finalIndexToDisplay,
  });

  RenderData<Ticker> getRenderData(final Ticker data, final double dx) =>
      RenderData<Ticker>(data: data, x: dx);

  final double height;
  List<Ticker> get data => dataSource.tickers;
  IndicatorRenderer? get render;
}
