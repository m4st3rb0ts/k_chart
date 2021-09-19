//
// Created by @sh1l0n
//

import 'package:flutter/material.dart';

import '../entity/k_line_entity.dart';
import '../renders/base_chart_renderer.dart';

abstract class Indicator {
  const Indicator({required this.dataSource});

  final List<KLineEntity> dataSource;

  BaseChartRenderer generateRender({
    required final Size size,
  });
}
