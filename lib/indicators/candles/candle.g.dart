// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Candle extends Candle {
  @override
  final double open;
  @override
  final double close;
  @override
  final double high;
  @override
  final double low;
  @override
  final double top;
  @override
  final double middle;
  @override
  final double bottom;
  @override
  final double bollMa;
  @override
  final BuiltList<double> maValueList;

  factory _$Candle([void Function(CandleBuilder)? updates]) =>
      (new CandleBuilder()..update(updates)).build();

  _$Candle._(
      {required this.open,
      required this.close,
      required this.high,
      required this.low,
      required this.top,
      required this.middle,
      required this.bottom,
      required this.bollMa,
      required this.maValueList})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(open, 'Candle', 'open');
    BuiltValueNullFieldError.checkNotNull(close, 'Candle', 'close');
    BuiltValueNullFieldError.checkNotNull(high, 'Candle', 'high');
    BuiltValueNullFieldError.checkNotNull(low, 'Candle', 'low');
    BuiltValueNullFieldError.checkNotNull(top, 'Candle', 'top');
    BuiltValueNullFieldError.checkNotNull(middle, 'Candle', 'middle');
    BuiltValueNullFieldError.checkNotNull(bottom, 'Candle', 'bottom');
    BuiltValueNullFieldError.checkNotNull(bollMa, 'Candle', 'bollMa');
    BuiltValueNullFieldError.checkNotNull(maValueList, 'Candle', 'maValueList');
  }

  @override
  Candle rebuild(void Function(CandleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CandleBuilder toBuilder() => new CandleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Candle &&
        open == other.open &&
        close == other.close &&
        high == other.high &&
        low == other.low &&
        top == other.top &&
        middle == other.middle &&
        bottom == other.bottom &&
        bollMa == other.bollMa &&
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
                            $jc($jc($jc(0, open.hashCode), close.hashCode),
                                high.hashCode),
                            low.hashCode),
                        top.hashCode),
                    middle.hashCode),
                bottom.hashCode),
            bollMa.hashCode),
        maValueList.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Candle')
          ..add('open', open)
          ..add('close', close)
          ..add('high', high)
          ..add('low', low)
          ..add('top', top)
          ..add('middle', middle)
          ..add('bottom', bottom)
          ..add('bollMa', bollMa)
          ..add('maValueList', maValueList))
        .toString();
  }
}

class CandleBuilder implements Builder<Candle, CandleBuilder> {
  _$Candle? _$v;

  double? _open;
  double? get open => _$this._open;
  set open(double? open) => _$this._open = open;

  double? _close;
  double? get close => _$this._close;
  set close(double? close) => _$this._close = close;

  double? _high;
  double? get high => _$this._high;
  set high(double? high) => _$this._high = high;

  double? _low;
  double? get low => _$this._low;
  set low(double? low) => _$this._low = low;

  double? _top;
  double? get top => _$this._top;
  set top(double? top) => _$this._top = top;

  double? _middle;
  double? get middle => _$this._middle;
  set middle(double? middle) => _$this._middle = middle;

  double? _bottom;
  double? get bottom => _$this._bottom;
  set bottom(double? bottom) => _$this._bottom = bottom;

  double? _bollMa;
  double? get bollMa => _$this._bollMa;
  set bollMa(double? bollMa) => _$this._bollMa = bollMa;

  ListBuilder<double>? _maValueList;
  ListBuilder<double> get maValueList =>
      _$this._maValueList ??= new ListBuilder<double>();
  set maValueList(ListBuilder<double>? maValueList) =>
      _$this._maValueList = maValueList;

  CandleBuilder();

  CandleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _open = $v.open;
      _close = $v.close;
      _high = $v.high;
      _low = $v.low;
      _top = $v.top;
      _middle = $v.middle;
      _bottom = $v.bottom;
      _bollMa = $v.bollMa;
      _maValueList = $v.maValueList.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Candle other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Candle;
  }

  @override
  void update(void Function(CandleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Candle build() {
    _$Candle _$result;
    try {
      _$result = _$v ??
          new _$Candle._(
              open:
                  BuiltValueNullFieldError.checkNotNull(open, 'Candle', 'open'),
              close: BuiltValueNullFieldError.checkNotNull(
                  close, 'Candle', 'close'),
              high:
                  BuiltValueNullFieldError.checkNotNull(high, 'Candle', 'high'),
              low: BuiltValueNullFieldError.checkNotNull(low, 'Candle', 'low'),
              top: BuiltValueNullFieldError.checkNotNull(top, 'Candle', 'top'),
              middle: BuiltValueNullFieldError.checkNotNull(
                  middle, 'Candle', 'middle'),
              bottom: BuiltValueNullFieldError.checkNotNull(
                  bottom, 'Candle', 'bottom'),
              bollMa: BuiltValueNullFieldError.checkNotNull(
                  bollMa, 'Candle', 'bollMa'),
              maValueList: maValueList.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'maValueList';
        maValueList.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Candle', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
