//
// Created by @sh1l0n
//

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'candle.g.dart';

abstract class Candle implements Built<Candle, CandleBuilder> {
  factory Candle([void Function(CandleBuilder)? updates]) = _$Candle;

  Candle._();
  double get open;
  double get close;
  double get high;
  double get low;
  double get top;
  double get middle;
  double get bottom;
  BuiltList<double> get maValueList;
}
