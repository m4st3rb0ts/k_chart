import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/chart_style.dart';
import 'package:k_chart/chart_translations.dart';
import 'package:k_chart/flutter_k_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<KLineEntity>? datas;
  bool showLoading = true;
  var _mainState = CandlesIndicators.MA;
  bool _volHidden = false;
  MacdIndicators _secondaryState = MacdIndicators.NONE;
  bool isLine = false;
  bool isChinese = true;
  bool _hideGrid = false;
  bool _showNowPrice = true;
  List<DepthEntity>? _bids, _asks;
  bool isChangeUI = false;

  ChartStyle chartStyle = ChartStyle();

  @override
  void initState() {
    super.initState();
    getData(period: '1day');
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      final tick = parseJson['tick'] as Map<String, dynamic>;
      final List<DepthEntity> bids = (tick['bids'] as List<dynamic>)
          .map<DepthEntity>(
              (item) => DepthEntity(item[0] as double, item[1] as double))
          .toList();
      final List<DepthEntity> asks = (tick['asks'] as List<dynamic>)
          .map<DepthEntity>(
              (item) => DepthEntity(item[0] as double, item[1] as double))
          .toList();
      initDepth(bids, asks);
    });
  }

  void initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    bids.sort((left, right) => left.price.compareTo(right.price));
    //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _bids!.insert(0, item);
    });

    amount = 0.0;
    asks.sort((left, right) => left.price.compareTo(right.price));
    //累加卖出委托量
    asks.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _asks!.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Stack(children: <Widget>[
          Container(
            width: double.infinity,
            height: 500,
            color: Colors.pink,
            child: IndicatorsPanel(
              datas: datas,
              chartStyle: chartStyle,
              fixedLength: 2,
              translations: kChartTranslations,
              showNowPrice: _showNowPrice,
              //`isChinese` is Deprecated, Use `translations` instead.
              hideGrid: _hideGrid,
              indicators: [
                CandlesIndicator(
                  dataSource: datas ?? <KLineEntity>[],
                  height: 300,
                  chartStyle: chartStyle,
                  displayTimeLineChart: isLine,
                  candleIndicator: _mainState,
                  maDayList: [1, 100, 1000],
                ),
                if (!_volHidden)
                  VolumeIndicator(
                    dataSource: datas ?? <KLineEntity>[],
                    height: 200,
                  ),
                // if (_secondaryState != MacdIndicators.NONE)
                //   MacdIndicator(
                //     dataSource: datas ?? <KLineEntity>[],
                //     indicator: _secondaryState,
                //     height: 200,
                //     chartStyle: chartStyle,
                //   ),
              ],
            ),
          ),
          if (showLoading)
            Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: const CircularProgressIndicator()),
        ]),
        buildButtons(),
        if (_bids != null && _asks != null)
          Container(
            height: 230,
            width: double.infinity,
            child: DepthChart(
              bids: _bids!,
              asks: _asks!,
              chartStyle: chartStyle,
            ),
          )
      ],
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("Time Mode", onPressed: () => isLine = true),
        button("K Line Mode", onPressed: () => isLine = false),
        button("Line:MA", onPressed: () => _mainState = CandlesIndicators.MA),
        button("Line:BOLL",
            onPressed: () => _mainState = CandlesIndicators.BOLL),
        button("Hide Line",
            onPressed: () => _mainState = CandlesIndicators.NONE),
        button("Secondary Chart:MACD",
            onPressed: () => _secondaryState = MacdIndicators.MACD),
        button("Secondary Chart:KDJ",
            onPressed: () => _secondaryState = MacdIndicators.KDJ),
        button("Secondary Chart:RSI",
            onPressed: () => _secondaryState = MacdIndicators.RSI),
        button("Secondary Chart:WR",
            onPressed: () => _secondaryState = MacdIndicators.WR),
        button("Secondary Chart:CCI",
            onPressed: () => _secondaryState = MacdIndicators.CCI),
        button("Secondary Chart:Hide",
            onPressed: () => _secondaryState = MacdIndicators.NONE),
        button(_volHidden ? "Show Vol" : "Hide Vol",
            onPressed: () => _volHidden = !_volHidden),
        button("Change Language", onPressed: () => isChinese = !isChinese),
        button(_hideGrid ? "Show Grid" : "Hide Grid",
            onPressed: () => _hideGrid = !_hideGrid),
        button(_showNowPrice ? "Hide Now Price" : "Show Now Price",
            onPressed: () => _showNowPrice = !_showNowPrice),
        button("Customize UI", onPressed: () {
          setState(() {
            this.isChangeUI = !this.isChangeUI;
            if (this.isChangeUI) {
              chartStyle.colors.selectBorderColor = Colors.red;
              chartStyle.colors.selectFillColor = Colors.red;
              chartStyle.colors.lineFillColor = Colors.red;
              chartStyle.colors.kLineColor = Colors.yellow;
            } else {
              chartStyle.colors.selectBorderColor = Color(0xff6C7A86);
              chartStyle.colors.selectFillColor = Color(0xff0D1722);
              chartStyle.colors.lineFillColor = Color(0x554C86CD);
              chartStyle.colors.kLineColor = Color(0xff4C86CD);
            }
          });
        }),
      ],
    );
  }

  Widget button(String text, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      child: Text(text),
      style: TextButton.styleFrom(
        primary: Colors.white,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void getData({required final String period}) {
    final Future<String> future = getIPAddress(period);
    future.then((String result) {
      final Map parseJson = json.decode(result) as Map<dynamic, dynamic>;
      final list = parseJson['data'] as List<dynamic>;
      datas = list
          .map((item) => KLineEntity.fromJson(item as Map<String, dynamic>))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      DataUtil.calculate(datas!);
      showLoading = false;
      setState(() {});
    }).catchError((_) {
      showLoading = false;
      setState(() {});
      print('### datas error $_');
    });
  }

  //获取火币数据，需要翻墙
  Future<String> getIPAddress(String? period) async {
    var url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    late String result;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      print('Failed getting IP address');
    }
    return result;
  }
}
