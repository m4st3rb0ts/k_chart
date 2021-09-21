//
// Created by @sh1l0n
//

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../entity/k_line_entity.dart';
import 'indicator_renderer.dart';

abstract class Indicator<T> {
  const Indicator({
    required this.dataSource,
    required this.height,
  });

  final List<KLineEntity> dataSource;
  void updateRender({
    required final Size size,
    required final double displayRectTop,
    required final double scale,
    required final int firstIndexToDisplay,
    required final int finalIndexToDisplay,
  });

  RenderData<T> getRenderData(final T data, final double dx) =>
      RenderData<T>(data: data, x: dx);

  final double height;
  BuiltList<T> get data;
  IndicatorRenderer<T>? get render;
  final double height;
}
