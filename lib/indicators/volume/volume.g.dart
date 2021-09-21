// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Volume extends Volume {
  @override
  final double open;
  @override
  final double close;
  @override
  final double vol;
  @override
  final double ma5Volume;
  @override
  final double ma10Volume;

  factory _$Volume([void Function(VolumeBuilder)? updates]) =>
      (new VolumeBuilder()..update(updates)).build();

  _$Volume._(
      {required this.open,
      required this.close,
      required this.vol,
      required this.ma5Volume,
      required this.ma10Volume})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(open, 'Volume', 'open');
    BuiltValueNullFieldError.checkNotNull(close, 'Volume', 'close');
    BuiltValueNullFieldError.checkNotNull(vol, 'Volume', 'vol');
    BuiltValueNullFieldError.checkNotNull(ma5Volume, 'Volume', 'ma5Volume');
    BuiltValueNullFieldError.checkNotNull(ma10Volume, 'Volume', 'ma10Volume');
  }

  @override
  Volume rebuild(void Function(VolumeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VolumeBuilder toBuilder() => new VolumeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Volume &&
        open == other.open &&
        close == other.close &&
        vol == other.vol &&
        ma5Volume == other.ma5Volume &&
        ma10Volume == other.ma10Volume;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, open.hashCode), close.hashCode), vol.hashCode),
            ma5Volume.hashCode),
        ma10Volume.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Volume')
          ..add('open', open)
          ..add('close', close)
          ..add('vol', vol)
          ..add('ma5Volume', ma5Volume)
          ..add('ma10Volume', ma10Volume))
        .toString();
  }
}

class VolumeBuilder implements Builder<Volume, VolumeBuilder> {
  _$Volume? _$v;

  double? _open;
  double? get open => _$this._open;
  set open(double? open) => _$this._open = open;

  double? _close;
  double? get close => _$this._close;
  set close(double? close) => _$this._close = close;

  double? _vol;
  double? get vol => _$this._vol;
  set vol(double? vol) => _$this._vol = vol;

  double? _ma5Volume;
  double? get ma5Volume => _$this._ma5Volume;
  set ma5Volume(double? ma5Volume) => _$this._ma5Volume = ma5Volume;

  double? _ma10Volume;
  double? get ma10Volume => _$this._ma10Volume;
  set ma10Volume(double? ma10Volume) => _$this._ma10Volume = ma10Volume;

  VolumeBuilder();

  VolumeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _open = $v.open;
      _close = $v.close;
      _vol = $v.vol;
      _ma5Volume = $v.ma5Volume;
      _ma10Volume = $v.ma10Volume;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Volume other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Volume;
  }

  @override
  void update(void Function(VolumeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Volume build() {
    final _$result = _$v ??
        new _$Volume._(
            open: BuiltValueNullFieldError.checkNotNull(open, 'Volume', 'open'),
            close:
                BuiltValueNullFieldError.checkNotNull(close, 'Volume', 'close'),
            vol: BuiltValueNullFieldError.checkNotNull(vol, 'Volume', 'vol'),
            ma5Volume: BuiltValueNullFieldError.checkNotNull(
                ma5Volume, 'Volume', 'ma5Volume'),
            ma10Volume: BuiltValueNullFieldError.checkNotNull(
                ma10Volume, 'Volume', 'ma10Volume'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
