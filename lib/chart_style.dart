//
// Created by @OpenFlutter
//

import 'package:flutter/material.dart' show Color;

class _ChartColors {
  Color nowPriceUpColor = Color(0xff4DAA90);
  Color nowPriceDnColor = Color(0xffC15466);
  Color nowPriceTextColor = Color(0xffffffff);

  //深度颜色
  Color depthBuyColor = Color(0xff60A893);
  Color depthSellColor = Color(0xffC15866);

  Color infoWindowNormalColor = Color(0xffffffff);
  Color infoWindowTitleColor = Color(0xffffffff);
  Color infoWindowUpColor = Color(0xff00ff00);
  Color infoWindowDnColor = Color(0xffff0000);

  //当前显示内最大和最小值的颜色
  Color maxColor = Color(0xffffffff);
  Color minColor = Color(0xffffffff);
}

class ChartStyle {
  //现在价格的线条长度
  double nowPriceLineLength = 1;

  //现在价格的线条间隔
  double nowPriceLineSpan = 1;

  final _ChartColors colors = _ChartColors();
}
