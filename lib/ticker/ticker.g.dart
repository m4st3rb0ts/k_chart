// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Ticker> _$tickerSerializer = new _$TickerSerializer();

class _$TickerSerializer implements StructuredSerializer<Ticker> {
  @override
  final Iterable<Type> types = const [Ticker, _$Ticker];
  @override
  final String wireName = 'Ticker';

  @override
  Iterable<Object?> serialize(Serializers serializers, Ticker object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'open',
      serializers.serialize(object.open, specifiedType: const FullType(double)),
      'high',
      serializers.serialize(object.high, specifiedType: const FullType(double)),
      'low',
      serializers.serialize(object.low, specifiedType: const FullType(double)),
      'close',
      serializers.serialize(object.close,
          specifiedType: const FullType(double)),
      'vol',
      serializers.serialize(object.vol, specifiedType: const FullType(double)),
      'amount',
      serializers.serialize(object.amount,
          specifiedType: const FullType(double)),
    ];
    Object? value;
    value = object.change;
    if (value != null) {
      result
        ..add('change')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.ratio;
    if (value != null) {
      result
        ..add('ratio')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.time;
    if (value != null) {
      result
        ..add('time')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.maValueList;
    if (value != null) {
      result
        ..add('maValueList')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(List, const [const FullType(double)])));
    }
    return result;
  }

  @override
  Ticker deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TickerBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'open':
          result.open = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'high':
          result.high = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'low':
          result.low = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'close':
          result.close = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'vol':
          result.vol = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'amount':
          result.amount = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'change':
          result.change = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'ratio':
          result.ratio = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'time':
          result.time = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'maValueList':
          result.maValueList = serializers.deserialize(value,
                  specifiedType:
                      const FullType(List, const [const FullType(double)]))
              as List<double>;
          break;
      }
    }

    return result.build();
  }
}

class _$Ticker extends Ticker {
  @override
  final double open;
  @override
  final double high;
  @override
  final double low;
  @override
  final double close;
  @override
  final double vol;
  @override
  final double amount;
  @override
  final double? change;
  @override
  final double? ratio;
  @override
  final int? time;
  @override
  final List<double>? maValueList;

  factory _$Ticker([void Function(TickerBuilder)? updates]) =>
      (new TickerBuilder()..update(updates)).build();

  _$Ticker._(
      {required this.open,
      required this.high,
      required this.low,
      required this.close,
      required this.vol,
      required this.amount,
      this.change,
      this.ratio,
      this.time,
      this.maValueList})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(open, 'Ticker', 'open');
    BuiltValueNullFieldError.checkNotNull(high, 'Ticker', 'high');
    BuiltValueNullFieldError.checkNotNull(low, 'Ticker', 'low');
    BuiltValueNullFieldError.checkNotNull(close, 'Ticker', 'close');
    BuiltValueNullFieldError.checkNotNull(vol, 'Ticker', 'vol');
    BuiltValueNullFieldError.checkNotNull(amount, 'Ticker', 'amount');
  }

  @override
  Ticker rebuild(void Function(TickerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TickerBuilder toBuilder() => new TickerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Ticker &&
        open == other.open &&
        high == other.high &&
        low == other.low &&
        close == other.close &&
        vol == other.vol &&
        amount == other.amount &&
        change == other.change &&
        ratio == other.ratio &&
        time == other.time &&
        maValueList == other.maValueList;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc($jc($jc(0, open.hashCode), high.hashCode),
                                    low.hashCode),
                                close.hashCode),
                            vol.hashCode),
                        amount.hashCode),
                    change.hashCode),
                ratio.hashCode),
            time.hashCode),
        maValueList.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Ticker')
          ..add('open', open)
          ..add('high', high)
          ..add('low', low)
          ..add('close', close)
          ..add('vol', vol)
          ..add('amount', amount)
          ..add('change', change)
          ..add('ratio', ratio)
          ..add('time', time)
          ..add('maValueList', maValueList))
        .toString();
  }
}

class TickerBuilder implements Builder<Ticker, TickerBuilder> {
  _$Ticker? _$v;

  double? _open;
  double? get open => _$this._open;
  set open(double? open) => _$this._open = open;

  double? _high;
  double? get high => _$this._high;
  set high(double? high) => _$this._high = high;

  double? _low;
  double? get low => _$this._low;
  set low(double? low) => _$this._low = low;

  double? _close;
  double? get close => _$this._close;
  set close(double? close) => _$this._close = close;

  double? _vol;
  double? get vol => _$this._vol;
  set vol(double? vol) => _$this._vol = vol;

  double? _amount;
  double? get amount => _$this._amount;
  set amount(double? amount) => _$this._amount = amount;

  double? _change;
  double? get change => _$this._change;
  set change(double? change) => _$this._change = change;

  double? _ratio;
  double? get ratio => _$this._ratio;
  set ratio(double? ratio) => _$this._ratio = ratio;

  int? _time;
  int? get time => _$this._time;
  set time(int? time) => _$this._time = time;

  List<double>? _maValueList;
  List<double>? get maValueList => _$this._maValueList;
  set maValueList(List<double>? maValueList) =>
      _$this._maValueList = maValueList;

  TickerBuilder();

  TickerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _open = $v.open;
      _high = $v.high;
      _low = $v.low;
      _close = $v.close;
      _vol = $v.vol;
      _amount = $v.amount;
      _change = $v.change;
      _ratio = $v.ratio;
      _time = $v.time;
      _maValueList = $v.maValueList;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Ticker other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Ticker;
  }

  @override
  void update(void Function(TickerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Ticker build() {
    final _$result = _$v ??
        new _$Ticker._(
            open: BuiltValueNullFieldError.checkNotNull(open, 'Ticker', 'open'),
            high: BuiltValueNullFieldError.checkNotNull(high, 'Ticker', 'high'),
            low: BuiltValueNullFieldError.checkNotNull(low, 'Ticker', 'low'),
            close:
                BuiltValueNullFieldError.checkNotNull(close, 'Ticker', 'close'),
            vol: BuiltValueNullFieldError.checkNotNull(vol, 'Ticker', 'vol'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, 'Ticker', 'amount'),
            change: change,
            ratio: ratio,
            time: time,
            maValueList: maValueList);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
