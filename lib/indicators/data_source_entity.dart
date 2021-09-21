import 'candles/candle_entity.dart';
import 'macd/kdj_entity.dart';
import 'macd/macd_entity.dart';
import 'macd/rsi_entity.dart';
import 'macd/rw_entity.dart';
import 'volume/volume_entity.dart';
import 'macd/cci_entity.dart';

class DataSourceEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {}
