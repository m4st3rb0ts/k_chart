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
    value = object.bollMa;
    if (value != null) {
      result
        ..add('bollMa')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.top;
    if (value != null) {
      result
        ..add('top')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.middle;
    if (value != null) {
      result
        ..add('middle')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.bottom;
    if (value != null) {
      result
        ..add('bottom')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.ma10Volume;
    if (value != null) {
      result
        ..add('ma10Volume')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.ma5Volume;
    if (value != null) {
      result
        ..add('ma5Volume')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.k;
    if (value != null) {
      result
        ..add('k')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.d;
    if (value != null) {
      result
        ..add('d')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.j;
    if (value != null) {
      result
        ..add('j')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.diff;
    if (value != null) {
      result
        ..add('diff')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.dea;
    if (value != null) {
      result
        ..add('dea')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.macd;
    if (value != null) {
      result
        ..add('macd')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.rsi;
    if (value != null) {
      result
        ..add('rsi')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.r;
    if (value != null) {
      result
        ..add('r')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.cci;
    if (value != null) {
      result
        ..add('cci')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
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
        case 'bollMa':
          result.bollMa = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'top':
          result.top = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'middle':
          result.middle = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'bottom':
          result.bottom = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'ma10Volume':
          result.ma10Volume = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'ma5Volume':
          result.ma5Volume = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'k':
          result.k = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'd':
          result.d = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'j':
          result.j = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'diff':
          result.diff = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'dea':
          result.dea = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'macd':
          result.macd = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'rsi':
          result.rsi = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'r':
          result.r = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'cci':
          result.cci = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
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
  @override
  final double? bollMa;
  @override
  final double? top;
  @override
  final double? middle;
  @override
  final double? bottom;
  @override
  final double? ma10Volume;
  @override
  final double? ma5Volume;
  @override
  final double? k;
  @override
  final double? d;
  @override
  final double? j;
  @override
  final double? diff;
  @override
  final double? dea;
  @override
  final double? macd;
  @override
  final double? rsi;
  @override
  final double? r;
  @override
  final double? cci;

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
      this.maValueList,
      this.bollMa,
      this.top,
      this.middle,
      this.bottom,
      this.ma10Volume,
      this.ma5Volume,
      this.k,
      this.d,
      this.j,
      this.diff,
      this.dea,
      this.macd,
      this.rsi,
      this.r,
      this.cci})
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
        maValueList == other.maValueList &&
        bollMa == other.bollMa &&
        top == other.top &&
        middle == other.middle &&
        bottom == other.bottom &&
        ma10Volume == other.ma10Volume &&
        ma5Volume == other.ma5Volume &&
        k == other.k &&
        d == other.d &&
        j == other.j &&
        diff == other.diff &&
        dea == other.dea &&
        macd == other.macd &&
        rsi == other.rsi &&
        r == other.r &&
        cci == other.cci;
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
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc($jc($jc($jc($jc(0, open.hashCode), high.hashCode), low.hashCode), close.hashCode), vol.hashCode), amount.hashCode),
                                                                                change.hashCode),
                                                                            ratio.hashCode),
                                                                        time.hashCode),
                                                                    maValueList.hashCode),
                                                                bollMa.hashCode),
                                                            top.hashCode),
                                                        middle.hashCode),
                                                    bottom.hashCode),
                                                ma10Volume.hashCode),
                                            ma5Volume.hashCode),
                                        k.hashCode),
                                    d.hashCode),
                                j.hashCode),
                            diff.hashCode),
                        dea.hashCode),
                    macd.hashCode),
                rsi.hashCode),
            r.hashCode),
        cci.hashCode));
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
          ..add('maValueList', maValueList)
          ..add('bollMa', bollMa)
          ..add('top', top)
          ..add('middle', middle)
          ..add('bottom', bottom)
          ..add('ma10Volume', ma10Volume)
          ..add('ma5Volume', ma5Volume)
          ..add('k', k)
          ..add('d', d)
          ..add('j', j)
          ..add('diff', diff)
          ..add('dea', dea)
          ..add('macd', macd)
          ..add('rsi', rsi)
          ..add('r', r)
          ..add('cci', cci))
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

  double? _bollMa;
  double? get bollMa => _$this._bollMa;
  set bollMa(double? bollMa) => _$this._bollMa = bollMa;

  double? _top;
  double? get top => _$this._top;
  set top(double? top) => _$this._top = top;

  double? _middle;
  double? get middle => _$this._middle;
  set middle(double? middle) => _$this._middle = middle;

  double? _bottom;
  double? get bottom => _$this._bottom;
  set bottom(double? bottom) => _$this._bottom = bottom;

  double? _ma10Volume;
  double? get ma10Volume => _$this._ma10Volume;
  set ma10Volume(double? ma10Volume) => _$this._ma10Volume = ma10Volume;

  double? _ma5Volume;
  double? get ma5Volume => _$this._ma5Volume;
  set ma5Volume(double? ma5Volume) => _$this._ma5Volume = ma5Volume;

  double? _k;
  double? get k => _$this._k;
  set k(double? k) => _$this._k = k;

  double? _d;
  double? get d => _$this._d;
  set d(double? d) => _$this._d = d;

  double? _j;
  double? get j => _$this._j;
  set j(double? j) => _$this._j = j;

  double? _diff;
  double? get diff => _$this._diff;
  set diff(double? diff) => _$this._diff = diff;

  double? _dea;
  double? get dea => _$this._dea;
  set dea(double? dea) => _$this._dea = dea;

  double? _macd;
  double? get macd => _$this._macd;
  set macd(double? macd) => _$this._macd = macd;

  double? _rsi;
  double? get rsi => _$this._rsi;
  set rsi(double? rsi) => _$this._rsi = rsi;

  double? _r;
  double? get r => _$this._r;
  set r(double? r) => _$this._r = r;

  double? _cci;
  double? get cci => _$this._cci;
  set cci(double? cci) => _$this._cci = cci;

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
      _bollMa = $v.bollMa;
      _top = $v.top;
      _middle = $v.middle;
      _bottom = $v.bottom;
      _ma10Volume = $v.ma10Volume;
      _ma5Volume = $v.ma5Volume;
      _k = $v.k;
      _d = $v.d;
      _j = $v.j;
      _diff = $v.diff;
      _dea = $v.dea;
      _macd = $v.macd;
      _rsi = $v.rsi;
      _r = $v.r;
      _cci = $v.cci;
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
            maValueList: maValueList,
            bollMa: bollMa,
            top: top,
            middle: middle,
            bottom: bottom,
            ma10Volume: ma10Volume,
            ma5Volume: ma5Volume,
            k: k,
            d: d,
            j: j,
            diff: diff,
            dea: dea,
            macd: macd,
            rsi: rsi,
            r: r,
            cci: cci);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
