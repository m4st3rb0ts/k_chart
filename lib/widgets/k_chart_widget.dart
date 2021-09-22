//
// Created by @OpenFlutter & @sh1l0n
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_chart/chart_translations.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/indicators/candles/candles_indicator.dart';
import 'package:k_chart/indicators/indicator.dart';
import 'package:k_chart/painters/chart_painter.dart';

class IndicatorsPanel extends StatefulWidget {
  const IndicatorsPanel({
    required this.datas,
    required this.indicators,
    this.onSecondaryTap,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.translations = kChartTranslations,
    this.onLoadMore,
    this.fixedLength = 2,
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.infoWindowNormalColor = const Color(0xffffffff),
    this.infoWindowTitleColor = const Color(0xffffffff),
    this.infoWindowUpColor = const Color(0xff00ff00),
    this.infoWindowDnColor = const Color(0xffff0000),
  });

  final List<KLineEntity>? datas;
  final Function()? onSecondaryTap;
  final bool hideGrid;
  final bool showNowPrice;
  final bool showInfoDialog;
  final Map<String, ChartTranslations> translations;

  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool)? onLoadMore;

  final int fixedLength;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;
  final List<Indicator> indicators;

<<<<<<< HEAD
  final Color infoWindowNormalColor;
  final Color infoWindowTitleColor;
  final Color infoWindowUpColor;
  final Color infoWindowDnColor;
=======
  const KChartWidget({
    required this.datas,
    required this.indicators,
    required this.chartStyle,
    this.onSecondaryTap,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.translations = kChartTranslations,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.fixedLength = 2,
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
  });
>>>>>>> aaec022 (update widget)

  @override
  _IndicatorsPanelState createState() => _IndicatorsPanelState();
}

class _IndicatorsPanelState extends State<IndicatorsPanel>
    with TickerProviderStateMixin {
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  StreamController<InfoWindowData?>? mInfoWindowStream;
  double mHeight = 0, mWidth = 0;
  AnimationController? _controller;
  Animation<double>? aniX;
  late DateFormat displayDateFormat;
  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;
  late List<String> infos;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity?>();

    displayDateFormat = DateFormat('MM/dd/yy');
    if ((widget.datas?.length ?? 0) > 1) {
      final firstTime = widget.datas?.first.time ?? 0;
      final secondTime = widget.datas?[1].time ?? 0;
      final time = (secondTime - firstTime) ~/ 1000;
      if (time >= 24 * 60 * 60 * 28) {
        displayDateFormat = DateFormat('MM/yy');
      } else if (time >= 24 * 60 * 60) {
        displayDateFormat = DateFormat('MM/dd/yy');
      } else {
        displayDateFormat = DateFormat('MM/dd/yy HH:mm');
      }
    }
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  double getMinScrollX() {
    return mScaleX;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = 0.0;
      mSelectX = 0.0;
      mScaleX = 1.0;
    }
    final _painter = ChartPainter(
      indicators: widget.indicators,
      dataSource: widget.datas ?? <KLineEntity>[],
      displayDateFormat: displayDateFormat,
      horizontalScale: mScaleX,
      currentHorizontalScroll: mScrollX,
      selectedHorizontalValue: mSelectX,
      shouldDisplaySelection: isLongPress,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      sink: mInfoWindowStream?.sink,
      fixedLength: widget.fixedLength,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;

        return GestureDetector(
          onTapUp: (details) {
            if (widget.onSecondaryTap != null) {
              widget.onSecondaryTap!();
            }
          },
          onHorizontalDragDown: (details) {
            _stopAnimation();
            _onDragChanged(true);
          },
          onHorizontalDragUpdate: (details) {
            if (isScale || isLongPress) return;
            mScrollX = (details.primaryDelta! / mScaleX + mScrollX)
                .clamp(
                    0.0,
                    _painter.maxHorizontalScrollWidth(
                        size: _painter.lastPaintedSize))
                .toDouble();
            notifyChanged();
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            var velocity = details.velocity.pixelsPerSecond.dx;
            _onFling(
                velocity,
                _painter.maxHorizontalScrollWidth(
                    size: _painter.lastPaintedSize));
          },
          onHorizontalDragCancel: () => _onDragChanged(false),
          onScaleStart: (_) {
            isScale = true;
          },
          onScaleUpdate: (details) {
            if (isDrag || isLongPress) return;
            mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
            notifyChanged();
          },
          onScaleEnd: (_) {
            isScale = false;
            _lastScale = mScaleX;
          },
          onLongPressStart: (details) {
            isLongPress = true;
            if (mSelectX != details.globalPosition.dx) {
              mSelectX = details.localPosition.dx;
              notifyChanged();
            }
          },
          onLongPressMoveUpdate: (details) {
            if (mSelectX != details.globalPosition.dx) {
              mSelectX = details.globalPosition.dx;
              notifyChanged();
            }
          },
          onLongPressEnd: (details) {
            isLongPress = false;
            mInfoWindowStream?.sink.add(null);
            notifyChanged();
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: _painter,
              ),
              if (widget.showInfoDialog) _buildInfoDialog(_painter)
            ],
          ),
        );
      },
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag!(isDrag);
    }
  }

  void _onFling(double x, final double maxScrollX) {
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.flingTime), vsync: this);
    aniX = null;
    aniX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX)
        .animate(CurvedAnimation(
            parent: _controller!.view, curve: widget.flingCurve));
    aniX!.addListener(() {
      mScrollX = aniX!.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(true);
        }
        _stopAnimation();
      } else if (mScrollX >= maxScrollX) {
        mScrollX = maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller!.forward();
  }

  void notifyChanged() => setState(() {});

  Widget _buildInfoDialog(final ChartPainter painter) {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress ||
              (widget.indicators.first as CandlesIndicator)
                  .displayTimeLineChart ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return Container();
          Ticker entity = snapshot.data!.kLineEntity;
          double upDown = entity.change ?? entity.close - entity.open;
          double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;
          infos = [
            getDate(entity.time),
            entity.open.toStringAsFixed(widget.fixedLength),
            entity.high.toStringAsFixed(widget.fixedLength),
            entity.low.toStringAsFixed(widget.fixedLength),
            entity.close.toStringAsFixed(widget.fixedLength),
            "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            entity.amount.toInt().toString()
          ];
          return Container(
            margin: EdgeInsets.only(
              left: snapshot.data!.isLeft ? 4 : mWidth - mWidth / 3 - 4,
              top: 25,
            ),
            width: mWidth / 3,
            decoration: BoxDecoration(
              color: painter.selectedFillColor,
              border: Border.all(
                color: painter.selectedBorderColor,
                width: 0.5,
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: infos.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final translations = kChartTranslations['en_US'];

                return _buildItem(
                  infos[index],
                  translations?.byIndex(index) ?? '',
                );
              },
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = widget.infoWindowNormalColor;
    if (info.startsWith("+"))
      color = widget.infoWindowUpColor;
    else if (info.startsWith("-")) color = widget.infoWindowDnColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            "$infoName",
            style: TextStyle(
              color: widget.infoWindowTitleColor,
              fontSize: 10.0,
            ),
          ),
        ),
        Text(
          info,
          style: TextStyle(
            color: color,
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }

  String getDate(final int? date) => displayDateFormat.format(
        DateTime.fromMillisecondsSinceEpoch(
          date ?? DateTime.now().millisecondsSinceEpoch,
        ),
      );
}
