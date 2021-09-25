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
  const DataSource({
    required this.tickers,
    this.maDayList = const [5, 10, 20],
    this.n = 20,
    this.k = 2,
  });

  final List<Ticker> tickers;
  final List<int> maDayList;
  final int n;
  final k;
}

// class DataSource {
//   DataSource(this._data) {
//     _calcMA(maDayList);
//     _calcBOLL(n, k);
//     _calcVolumeMA();
//     _calcKDJ();
//     _calcMACD();
//     _calcRSI();
//     _calcWR();
//     _calcCCI();
//   }
//   late List<DataSourceEntity> _data;
//   // List<DataSourceEntity> get data => data;

//   void _calcMA(List<int> maDayList) {
//     List<double> ma = List<double>.filled(maDayList.length, 0);

//     if (_data.isNotEmpty) {
//       for (int i = 0; i < _data.length; i++) {
//         Ticker entity = _data[i];
//         final closePrice = entity.close;
//         entity.maValueList = List<double>.filled(maDayList.length, 0);

//         for (int j = 0; j < maDayList.length; j++) {
//           ma[j] += closePrice;
//           if (i == maDayList[j] - 1) {
//             entity.maValueList?[j] = ma[j] / maDayList[j];
//           } else if (i >= maDayList[j]) {
//             ma[j] -= _data[i - maDayList[j]].close;
//             entity.maValueList?[j] = ma[j] / maDayList[j];
//           } else {
//             entity.maValueList?[j] = 0;
//           }
//         }
//       }
//     }
//   }

//   void _calcBOLL(int n, int k) {
//     _calcBOLLMA(n);
//     for (int i = 0; i < _data.length; i++) {
//       Ticker entity = _data[i];
//       if (i >= n) {
//         double md = 0;
//         for (int j = i - n + 1; j <= i; j++) {
//           double c = _data[j].close;
//           double m = entity.BOLLMA!;
//           double value = c - m;
//           md += value * value;
//         }
//         md = md / (n - 1);
//         md = sqrt(md);
//         entity.middle = entity.BOLLMA!;
//         entity.top = entity.middle! + k * md;
//         entity.bottom = entity.middle! - k * md;
//       }
//     }
//   }

//   void _calcBOLLMA(int day) {
//     double ma = 0;
//     for (int i = 0; i < _data.length; i++) {
//       Ticker entity = _data[i];
//       ma += entity.close;
//       if (i == day - 1) {
//         entity.BOLLMA = ma / day;
//       } else if (i >= day) {
//         ma -= _data[i - day].close;
//         entity.BOLLMA = ma / day;
//       } else {
//         entity.BOLLMA = null;
//       }
//     }
//   }

//   void _calcMACD() {
//     double ema12 = 0;
//     double ema26 = 0;
//     double dif = 0;
//     double dea = 0;
//     double macd = 0;

//     for (int i = 0; i < _data.length; i++) {
//       Ticker entity = _data[i];
//       final closePrice = entity.close;
//       if (i == 0) {
//         ema12 = closePrice;
//         ema26 = closePrice;
//       } else {
//         // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
//         ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
//         // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
//         ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
//       }
//       // DIF = EMA（12） - EMA（26） 。
//       // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
//       // 用（DIF-DEA）*2即为MACD柱状图。
//       dif = ema12 - ema26;
//       dea = dea * 8 / 10 + dif * 2 / 10;
//       macd = (dif - dea) * 2;
//       entity.dif = dif;
//       entity.dea = dea;
//       entity.macd = macd;
//     }
//   }

//   void _calcVolumeMA() {
//     double volumeMa5 = 0;
//     double volumeMa10 = 0;

//     for (int i = 0; i < _data.length; i++) {
//       Ticker entry = _data[i];

//       volumeMa5 += entry.vol;
//       volumeMa10 += entry.vol;

//       if (i == 4) {
//         entry.MA5Volume = (volumeMa5 / 5);
//       } else if (i > 4) {
//         volumeMa5 -= _data[i - 5].vol;
//         entry.MA5Volume = volumeMa5 / 5;
//       } else {
//         entry.MA5Volume = 0;
//       }

//       if (i == 9) {
//         entry.MA10Volume = volumeMa10 / 10;
//       } else if (i > 9) {
//         volumeMa10 -= _data[i - 10].vol;
//         entry.MA10Volume = volumeMa10 / 10;
//       } else {
//         entry.MA10Volume = 0;
//       }
//     }
//   }

//   void _calcRSI() {
//     double? rsi;
//     double rsiABSEma = 0;
//     double rsiMaxEma = 0;
//     for (int i = 0; i < _data.length; i++) {
//       Ticker entity = _data[i];
//       final double closePrice = entity.close;
//       if (i == 0) {
//         rsi = 0;
//         rsiABSEma = 0;
//         rsiMaxEma = 0;
//       } else {
//         double Rmax = max(0, closePrice - _data[i - 1].close.toDouble());
//         double RAbs = (closePrice - _data[i - 1].close.toDouble()).abs();

//         rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
//         rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
//         rsi = (rsiMaxEma / rsiABSEma) * 100;
//       }
//       if (i < 13) rsi = null;
//       if (rsi != null && rsi.isNaN) rsi = null;
//       entity.rsi = rsi;
//     }
//   }

//   void _calcKDJ() {
//     var preK = 50.0;
//     var preD = 50.0;
//     final tmp = _data.first;
//     tmp.k = preK;
//     tmp.d = preD;
//     tmp.j = 50.0;
//     for (int i = 1; i < _data.length; i++) {
//       final entity = _data[i];
//       final n = max(0, i - 8);
//       var low = entity.low;
//       var high = entity.high;
//       for (int j = n; j < i; j++) {
//         final t = _data[j];
//         if (t.low < low) {
//           low = t.low;
//         }
//         if (t.high > high) {
//           high = t.high;
//         }
//       }
//       final cur = entity.close;
//       var rsv = (cur - low) * 100.0 / (high - low);
//       rsv = rsv.isNaN ? 0 : rsv;
//       final k = (2 * preK + rsv) / 3.0;
//       final d = (2 * preD + k) / 3.0;
//       final j = 3 * k - 2 * d;
//       preK = k;
//       preD = d;
//       entity.k = k;
//       entity.d = d;
//       entity.j = j;
//     }
//   }

//   void _calcWR() {
//     double r;
//     for (int i = 0; i < _data.length; i++) {
//       Ticker entity = _data[i];
//       int startIndex = i - 14;
//       if (startIndex < 0) {
//         startIndex = 0;
//       }
//       double max14 = double.minPositive;
//       double min14 = double.maxFinite;
//       for (int index = startIndex; index <= i; index++) {
//         max14 = max(max14, _data[index].high);
//         min14 = min(min14, _data[index].low);
//       }
//       if (i < 13) {
//         entity.r = -10;
//       } else {
//         r = -100 * (max14 - _data[i].close) / (max14 - min14);
//         if (r.isNaN) {
//           entity.r = null;
//         } else {
//           entity.r = r;
//         }
//       }
//     }
//   }

//   void _calcCCI() {
//     final size = _data.length;
//     final count = 14;
//     for (int i = 0; i < size; i++) {
//       final kline = _data[i];
//       final tp = (kline.high + kline.low + kline.close) / 3;
//       final start = max(0, i - count + 1);
//       var amount = 0.0;
//       var len = 0;
//       for (int n = start; n <= i; n++) {
//         amount += (_data[n].high + _data[n].low + _data[n].close) / 3;
//         len++;
//       }
//       final ma = amount / len;
//       amount = 0.0;
//       for (int n = start; n <= i; n++) {
//         amount += (ma - (_data[n].high + _data[n].low + _data[n].close) / 3).abs();
//       }
//       final md = amount / len;
//       kline.cci = ((tp - ma) / 0.015 / md);
//       if (kline.cci!.isNaN) {
//         kline.cci = 0.0;
//       }
//     }
//   }
// }
