//
// Created by @sh1l0n
//

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';

import '../entity/k_line_entity.dart';
import '../renders/base_chart_renderer.dart';

abstract class Indicator<T> {
  const Indicator({required this.dataSource});

  final List<KLineEntity> dataSource;
  void updateRender({
    required final Size size,
    required final double scale,
    required final int startIndex,
    required final int stopIndex,
  });

  BuiltList<T> get data;
  BaseChartRenderer? get render;
}
