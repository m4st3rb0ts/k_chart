//
// Created by @sh1l0n
//

import 'package:built_value/built_value.dart';

part 'volume.g.dart';

abstract class Volume implements Built<Volume, VolumeBuilder> {
  factory Volume([void Function(VolumeBuilder)? updates]) = _$Volume;

  Volume._();
  double get open;
  double get close;
  double get vol;
  double get ma5Volume;
  double get ma10Volume;
}
