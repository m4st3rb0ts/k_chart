//
// Created by @OpenFlutter & @sh1l0n
//

import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'ticker.dart';

class DataSource {
  DataSource({
    required final List<Ticker> tickers,
    this.maDayList = const [5, 10, 20],
    this.computeFromStartDayNumber = 20,
    this.k = 2,
  }) {
    _tickers = <Ticker>[]..addAll(tickers);
    _calcMA();
    _calcBOLL();
    _calcVolumeMA();
    _calcKDJ();
    _calcMACD();
    _calcRSI();
    _calcWR();
    _calcCCI();
  }

  late List<Ticker> _tickers;
  List<Ticker> get tickers => _tickers;

  final List<int> maDayList;
  final int computeFromStartDayNumber;
  final k;

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

  void _calcBOLL() {
    _calcBOLLMA();
    for (var i = 0; i < tickers.length; i++) {
      final entity = tickers[i];
      if (i >= computeFromStartDayNumber) {
        double md = 0;
        for (int j = i - computeFromStartDayNumber + 1; j <= i; j++) {
          final c = tickers[j].close;
          final m = entity.bollMa ?? 0;
          final value = c - m;
          md += value * value;
        }
        md = md / (computeFromStartDayNumber - 1);
        md = sqrt(md);
        _tickers[i] = _tickers[i].rebuild(
          (t) => t
            ..middle = entity.bollMa ?? 0
            ..top = (entity.middle ?? 0) + k * md
            ..bottom = (entity.middle ?? 0) - k * md,
        );
      }
    }
  }

  void _calcBOLLMA() {
    double ma = 0;
    for (int i = 0; i < tickers.length; i++) {
      Ticker entity = tickers[i];
      ma += entity.close;
      if (i == computeFromStartDayNumber - 1) {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..BOLLMA = ma / computeFromStartDayNumber,
        );
      } else if (i >= computeFromStartDayNumber) {
        ma -= tickers[i - computeFromStartDayNumber].close;
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..BOLLMA = ma / computeFromStartDayNumber,
        );
      }
    }
  }

  void _calcVolumeMA() {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    for (int i = 0; i < tickers.length; i++) {
      Ticker entry = tickers[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..MA5Volume = (volumeMa5 / 5),
        );
      } else if (i > 4) {
        volumeMa5 -= tickers[i - 5].vol;
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..MA5Volume = (volumeMa5 / 5),
        );
      } else {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..MA5Volume = 0,
        );
      }

      if (i == 9) {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..MA10Volume = volumeMa10 / 10,
        );
      } else if (i > 9) {
        volumeMa10 -= tickers[i - 10].vol;
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..MA10Volume = volumeMa10 / 10,
        );
      } else {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..MA10Volume = 0,
        );
      }
    }
  }

  void _calcKDJ() {
    var preK = 50.0;
    var preD = 50.0;
    for (var i = 1; i < tickers.length; i++) {
      final entity = tickers[i];
      final n = max(0, i - 8);
      var low = entity.low;
      var high = entity.high;
      for (var j = n; j < i; j++) {
        final t = tickers[j];
        if (t.low < low) {
          low = t.low;
        }
        if (t.high > high) {
          high = t.high;
        }
      }
      final cur = entity.close;
      var rsv = (cur - low) * 100.0 / (high - low);
      rsv = rsv.isNaN ? 0 : rsv;
      final k = (2 * preK + rsv) / 3.0;
      final d = (2 * preD + k) / 3.0;
      final j = 3 * k - 2 * d;
      preK = k;
      preD = d;
      _tickers[i] = _tickers[i].rebuild(
        (t) => t
          ..k = k
          ..d = d
          ..j = j,
      );
    }
  }

  void _calcMACD() {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (var i = 0; i < tickers.length; i++) {
      final entity = tickers[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * 8 / 10 + dif * 2 / 10;
      macd = (dif - dea) * 2;

      _tickers[i] = _tickers[i].rebuild(
        (t) => t
          ..diff = dif
          ..dea = dea
          ..macd = macd,
      );
    }
  }

  void _calcRSI() {
    double? rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < tickers.length; i++) {
      Ticker entity = tickers[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double Rmax = max(0, closePrice - tickers[i - 1].close.toDouble());
        double RAbs = (closePrice - tickers[i - 1].close.toDouble()).abs();

        rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
        rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < 13) rsi = null;
      if (rsi != null && rsi.isNaN) rsi = null;
      _tickers[i] = _tickers[i].rebuild(
        (t) => t..rsi = rsi,
      );
    }
  }

  void _calcWR() {
    double r;
    for (int i = 0; i < tickers.length; i++) {
      Ticker entity = tickers[i];
      int startIndex = i - 14;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = double.minPositive;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, tickers[index].high);
        min14 = min(min14, tickers[index].low);
      }
      if (i < 13) {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..r = -10,
        );
      } else {
        r = -100 * (max14 - tickers[i].close) / (max14 - min14);
        if (r.isNaN) {
          _tickers[i] = _tickers[i].rebuild(
            (t) => t..r = null,
          );
        } else {
          _tickers[i] = _tickers[i].rebuild(
            (t) => t..r = r,
          );
        }
      }
    }
  }

  void _calcCCI() {
    final size = tickers.length;
    final count = 14;
    for (int i = 0; i < size; i++) {
      final kline = tickers[i];
      final tp = (kline.high + kline.low + kline.close) / 3;
      final start = max(0, i - count + 1);
      var amount = 0.0;
      var len = 0;
      for (int n = start; n <= i; n++) {
        amount += (tickers[n].high + tickers[n].low + tickers[n].close) / 3;
        len++;
      }
      final ma = amount / len;
      amount = 0.0;
      for (int n = start; n <= i; n++) {
        amount +=
            (ma - (tickers[n].high + tickers[n].low + tickers[n].close) / 3)
                .abs();
      }
      final md = amount / len;
      _tickers[i] = _tickers[i].rebuild(
        (t) => t..cci = ((tp - ma) / 0.015 / md),
      );
      if (kline.cci!.isNaN) {
        _tickers[i] = _tickers[i].rebuild(
          (t) => t..cci = 0.0,
        );
      }
    }
  }
}
