//
// Created by @sh1l0n
//

import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import '../ticker/ticker.dart';

part 'serializers.g.dart';

/// Collection of generated serializers for the built_value chat example.
@SerializersFor([
  Ticker,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
