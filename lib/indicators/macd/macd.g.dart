// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macd.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Macd extends Macd {
  @override
  final double k;
  @override
  final double d;
  @override
  final double j;
  @override
  final double rsi;
  @override
  final double r;
  @override
  final double cci;
  @override
  final double macd;
  @override
  final double dif;
  @override
  final double dea;

  factory _$Macd([void Function(MacdBuilder)? updates]) =>
      (new MacdBuilder()..update(updates)).build();

  _$Macd._(
      {required this.k,
      required this.d,
      required this.j,
      required this.rsi,
      required this.r,
      required this.cci,
      required this.macd,
      required this.dif,
      required this.dea})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(k, 'Macd', 'k');
    BuiltValueNullFieldError.checkNotNull(d, 'Macd', 'd');
    BuiltValueNullFieldError.checkNotNull(j, 'Macd', 'j');
    BuiltValueNullFieldError.checkNotNull(rsi, 'Macd', 'rsi');
    BuiltValueNullFieldError.checkNotNull(r, 'Macd', 'r');
    BuiltValueNullFieldError.checkNotNull(cci, 'Macd', 'cci');
    BuiltValueNullFieldError.checkNotNull(macd, 'Macd', 'macd');
    BuiltValueNullFieldError.checkNotNull(dif, 'Macd', 'dif');
    BuiltValueNullFieldError.checkNotNull(dea, 'Macd', 'dea');
  }

  @override
  Macd rebuild(void Function(MacdBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MacdBuilder toBuilder() => new MacdBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Macd &&
        k == other.k &&
        d == other.d &&
        j == other.j &&
        rsi == other.rsi &&
        r == other.r &&
        cci == other.cci &&
        macd == other.macd &&
        dif == other.dif &&
        dea == other.dea;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc($jc($jc(0, k.hashCode), d.hashCode),
                                j.hashCode),
                            rsi.hashCode),
                        r.hashCode),
                    cci.hashCode),
                macd.hashCode),
            dif.hashCode),
        dea.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Macd')
          ..add('k', k)
          ..add('d', d)
          ..add('j', j)
          ..add('rsi', rsi)
          ..add('r', r)
          ..add('cci', cci)
          ..add('macd', macd)
          ..add('dif', dif)
          ..add('dea', dea))
        .toString();
  }
}

class MacdBuilder implements Builder<Macd, MacdBuilder> {
  _$Macd? _$v;

  double? _k;
  double? get k => _$this._k;
  set k(double? k) => _$this._k = k;

  double? _d;
  double? get d => _$this._d;
  set d(double? d) => _$this._d = d;

  double? _j;
  double? get j => _$this._j;
  set j(double? j) => _$this._j = j;

  double? _rsi;
  double? get rsi => _$this._rsi;
  set rsi(double? rsi) => _$this._rsi = rsi;

  double? _r;
  double? get r => _$this._r;
  set r(double? r) => _$this._r = r;

  double? _cci;
  double? get cci => _$this._cci;
  set cci(double? cci) => _$this._cci = cci;

  double? _macd;
  double? get macd => _$this._macd;
  set macd(double? macd) => _$this._macd = macd;

  double? _dif;
  double? get dif => _$this._dif;
  set dif(double? dif) => _$this._dif = dif;

  double? _dea;
  double? get dea => _$this._dea;
  set dea(double? dea) => _$this._dea = dea;

  MacdBuilder();

  MacdBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _k = $v.k;
      _d = $v.d;
      _j = $v.j;
      _rsi = $v.rsi;
      _r = $v.r;
      _cci = $v.cci;
      _macd = $v.macd;
      _dif = $v.dif;
      _dea = $v.dea;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Macd other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Macd;
  }

  @override
  void update(void Function(MacdBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Macd build() {
    final _$result = _$v ??
        new _$Macd._(
            k: BuiltValueNullFieldError.checkNotNull(k, 'Macd', 'k'),
            d: BuiltValueNullFieldError.checkNotNull(d, 'Macd', 'd'),
            j: BuiltValueNullFieldError.checkNotNull(j, 'Macd', 'j'),
            rsi: BuiltValueNullFieldError.checkNotNull(rsi, 'Macd', 'rsi'),
            r: BuiltValueNullFieldError.checkNotNull(r, 'Macd', 'r'),
            cci: BuiltValueNullFieldError.checkNotNull(cci, 'Macd', 'cci'),
            macd: BuiltValueNullFieldError.checkNotNull(macd, 'Macd', 'macd'),
            dif: BuiltValueNullFieldError.checkNotNull(dif, 'Macd', 'dif'),
            dea: BuiltValueNullFieldError.checkNotNull(dea, 'Macd', 'dea'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
