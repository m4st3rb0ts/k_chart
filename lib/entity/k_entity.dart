//
// Created by @OpenFlutter
//

import '../indicators/volume/entity/volume_entity.dart';
import '../indicators/macd/entity/cci_entity.dart';
import '../indicators/macd/entity/rsi_entity.dart';
import '../indicators/macd/entity/kdj_entity.dart';
import '../indicators/macd/entity/rw_entity.dart';
import '../indicators/macd/entity/macd_entity.dart';
import '../indicators/candles/entity/candle_entity.dart';

class KEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {}
