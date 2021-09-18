import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show MainState;
import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  MainRenderer({
    required final Rect mainRect,
    required double maxValue,
    required double minValue,
    required final double topPadding,
    required this.state,
    required this.isLine,
    required final int fixedLength,
    required this.chartStyle,
    required this.chartColors,
    required this.scaleX,
    this.maDayList = const [5, 10, 20],
  }) : super(
            chartRect: mainRect,
            maxYValue: maxValue,
            minYValue: minValue,
            topPadding: topPadding,
            fixedDecimalsLength: fixedLength,
            gridColor: chartColors.gridColor) {
    mCandleWidth = this.chartStyle.candleWidth;
    mCandleLineWidth = this.chartStyle.candleLineWidth;
    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = mLineStrokeWidth
      ..color = this.chartColors.kLineColor;
    _contentRect = Rect.fromLTRB(
        chartRect.left,
        chartRect.top + _contentPadding,
        chartRect.right,
        chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  late double mCandleWidth;
  late double mCandleLineWidth;
  final MainState state;
  final bool isLine;

  //绘制的内容区域
  late Rect _contentRect;
  final double _contentPadding = 5.0;
  List<int> maDayList;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final double mLineStrokeWidth = 1.0;
  double scaleX;
  late Paint mLinePaint;

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void drawText({
    required final Canvas canvas,
    required final CandleEntity data,
    required final double x,
  }) {
    if (isLine == true) return;
    TextSpan? span;
    if (state == MainState.MA) {
      span = TextSpan(
        children: _createMATextSpan(data: data),
      );
    } else if (state == MainState.BOLL) {
      span = TextSpan(
        children: [
          if (data.up != 0)
            TextSpan(
                text: "BOLL:${format(n: data.mb)}    ",
                style: getTextStyle(color: chartColors.ma5Color)),
          if (data.mb != 0)
            TextSpan(
                text: "UB:${format(n: data.up)}    ",
                style: getTextStyle(color: chartColors.ma10Color)),
          if (data.dn != 0)
            TextSpan(
                text: "LB:${format(n: data.dn)}    ",
                style: getTextStyle(color: chartColors.ma30Color)),
        ],
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  List<InlineSpan> _createMATextSpan({required final CandleEntity data}) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        var item = TextSpan(
            text: "MA${maDayList[i]}:${format(n: data.maValueList![i])}    ",
            style: getTextStyle(color: chartColors.getMAColor(i)));
        result.add(item);
      }
    }
    return result;
  }

  @override
  void drawChart({
    required final CandleEntity lastPoint,
    required final CandleEntity curPoint,
    required final double lastX,
    required final double curX,
    required final Size size,
    required final Canvas canvas,
  }) {
    if (isLine != true) {
      drawCandle(curPoint: curPoint, canvas: canvas, curX: curX);
    }
    if (isLine == true) {
      drawPolyline(
        lastPrice: lastPoint.close,
        curPrice: curPoint.close,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
      );
    } else if (state == MainState.MA) {
      drawMaLine(
        lastPoint: lastPoint,
        curPoint: curPoint,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
      );
    } else if (state == MainState.BOLL) {
      drawBollLine(
        lastPoint: lastPoint,
        curPoint: curPoint,
        canvas: canvas,
        lastX: lastX,
        curX: curX,
      );
    }
  }

  //画折线图
  drawPolyline({
    required final double lastPrice,
    required final double curPrice,
    required final Canvas canvas,
    required double lastX,
    required final double curX,
  }) {
//    drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

//    if (lastX == curX) {
//      mLinePath.moveTo(lastX, getY(lastPrice));
//    } else {
////      mLinePath.lineTo(curX, getY(curPrice));
//      mLinePath.cubicTo(
//          (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
//    }
    if (lastX == curX) {
      lastX = 0;
    } //起点位置填充
    mLinePath!.moveTo(lastX, getVerticalPositionForPoint(value: lastPrice));
    mLinePath!.cubicTo(
        (lastX + curX) / 2,
        getVerticalPositionForPoint(value: lastPrice),
        (lastX + curX) / 2,
        getVerticalPositionForPoint(value: curPrice),
        curX,
        getVerticalPositionForPoint(value: curPrice));

    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [this.chartColors.lineFillColor, Colors.transparent],
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath!.lineTo(lastX, getVerticalPositionForPoint(value: lastPrice));
    mLineFillPath!.cubicTo(
        (lastX + curX) / 2,
        getVerticalPositionForPoint(value: lastPrice),
        (lastX + curX) / 2,
        getVerticalPositionForPoint(value: curPrice),
        curX,
        getVerticalPositionForPoint(value: curPrice));
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();

    canvas.drawPath(mLinePath!,
        mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0));
    mLinePath!.reset();
  }

  void drawMaLine({
    required final CandleEntity lastPoint,
    required final CandleEntity curPoint,
    required final Canvas canvas,
    required final double lastX,
    required final double curX,
  }) {
    for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.maValueList?[i] != 0) {
        drawLine(
          lastPrice: lastPoint.maValueList?[i],
          curPrice: curPoint.maValueList?[i],
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.getMAColor(i),
        );
      }
    }
  }

  void drawBollLine({
    required final CandleEntity lastPoint,
    required final CandleEntity curPoint,
    required final Canvas canvas,
    required final double lastX,
    required final double curX,
  }) {
    if (lastPoint.up != 0) {
      drawLine(
          lastPrice: lastPoint.up,
          curPrice: curPoint.up,
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(
          lastPrice: lastPoint.mb,
          curPrice: curPoint.mb,
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(
          lastPrice: lastPoint.dn,
          curPrice: curPoint.dn,
          canvas: canvas,
          lastX: lastX,
          curX: curX,
          color: chartColors.ma30Color);
    }
  }

  void drawCandle({
    required final CandleEntity curPoint,
    required final Canvas canvas,
    required final double curX,
  }) {
    var high = getVerticalPositionForPoint(value: curPoint.high);
    var low = getVerticalPositionForPoint(value: curPoint.low);
    var open = getVerticalPositionForPoint(value: curPoint.open);
    var close = getVerticalPositionForPoint(value: curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    if (open >= close) {
      // 实体高度>= CandleLineWidth
      if (open - close < mCandleLineWidth) {
        open = close + mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else if (close > open) {
      // 实体高度>= CandleLineWidth
      if (close - open < mCandleLineWidth) {
        open = close - mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    }
  }

  @override
  void drawRightText({
    required final Canvas canvas,
    required final textStyle,
    required final int gridRows,
  }) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minYValue;
      TextSpan span = TextSpan(text: "${format(n: value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      if (i == 0) {
        tp.paint(canvas, Offset(0, topPadding));
      } else {
        tp.paint(canvas, Offset(0, rowSpace * i - tp.height + topPadding));
      }
    }
  }

  @override
  void drawGrid({
    required final Canvas canvas,
    required final int gridRows,
    required final int gridColumns,
  }) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, topPadding / 3),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }

  @override
  double getVerticalPositionForPoint({required double value}) {
    return (maxYValue - value) * scaleY + _contentRect.top;
  }
}
