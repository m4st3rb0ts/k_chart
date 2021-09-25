//
// Created by @OpenFlutter
//

import '../ticker/ticker.dart';

class InfoWindowEntity {
  Ticker kLineEntity;
  bool isLeft;

  InfoWindowEntity(
    this.kLineEntity, {
    this.isLeft = false,
  });
}
