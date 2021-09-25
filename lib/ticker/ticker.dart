//
// Created by @OpenFlutter & @sh1l0n
//

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import '../serializers.dart';

part 'ticker.g.dart';

abstract class Ticker implements Built<Ticker, TickerBuilder> {
  factory Ticker([void Function(TickerBuilder)? updates]) = _$Ticker;
  Ticker._();

  double get open;
  double get high;
  double get low;
  double get close;
  double get vol;
  double get amount;
  double? get change;
  double? get ratio;
  int? get time;

  static Serializer<Ticker> get serializer => _$tickerSerializer;

  Map<String, dynamic>? toJson() =>
      serializers.serializeWith(Ticker.serializer, this)
          as Map<String, dynamic>?;

  static Ticker? fromJson(final Map<String, dynamic> json) {
    return serializers.deserializeWith(Ticker.serializer, json);
  }
}
