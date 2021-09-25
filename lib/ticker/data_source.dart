//
// Created by @OpenFlutter & @sh1l0n
//

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ticker.dart';
import '../indicators/candles/entity/candle_entity.dart';
import '../indicators/macd/entity/kdj_entity.dart';
import '../indicators/macd/entity/macd_entity.dart';
import '../indicators/macd/entity/rsi_entity.dart';
import '../indicators/macd/entity/rw_entity.dart';
import '../indicators/volume/entity/volume_entity.dart';
import '../indicators/macd/entity/cci_entity.dart';

class DataSourceEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {}

class DataSource {
  DataSource({
    required final List<Ticker> tickers,
    this.maDayList = const [5, 10, 20],
    this.n = 20,
    this.k = 2,
  }) {
    _tickers = <Ticker>[]..addAll(tickers);
    _calcMA();
  }

  static Future<DataSource> fromUrl(final String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final result = response.body;
      final Map parseJson = jsonDecode(result) as Map<String, dynamic>;
      final list = parseJson['data'] as List<dynamic>;
      final tickers = list
          .map((item) => Ticker.fromJson(item as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
      return DataSource(tickers: tickers.cast<Ticker>());
    } else {
      return DataSource(tickers: []);
    }
  }

  late List<Ticker> _tickers;
  List<Ticker> get tickers => _tickers;

  final List<int> maDayList;
  final int n;
  final k;

  void _calcMA() {
    List<double> ma = List<double>.filled(maDayList.length, 0);

    if (_tickers.isNotEmpty) {
      for (int i = 0; i < _tickers.length; i++) {
        final closePrice = _tickers[i].close;
        _tickers[i] = _tickers[i].rebuild(
            (t) => t.maValueList = List<double>.filled(maDayList.length, 0));

        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            _tickers[i] = _tickers[i]
                .rebuild((t) => t.maValueList?[j] = ma[j] / maDayList[j]);
          } else if (i >= maDayList[j]) {
            ma[j] -= _tickers[i - maDayList[j]].close;
            _tickers[i] = _tickers[i]
                .rebuild((t) => t.maValueList?[j] = ma[j] / maDayList[j]);
          } else {
            _tickers[i] = _tickers[i].rebuild((t) => t.maValueList?[j] = 0);
          }
        }
      }
    }
  }
}
