//
// Created by @sh1l0n
//

import 'package:built_value/built_value.dart';

part 'macd.g.dart';

enum MacdIndicators { MACD, KDJ, RSI, WR, CCI, NONE }

abstract class Macd implements Built<Macd, MacdBuilder> {
  factory Macd([void Function(MacdBuilder)? updates]) = _$Macd;

  Macd._();

  double get k;
  double get d;
  double get j;
  double get rsi;
  double get r;
  double get cci;
  double get macd;
  double get dif;
  double get dea;
}
