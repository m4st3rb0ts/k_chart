//
// Created by @OpenFlutter & @sh1l0n
//

import 'package:flutter/widgets.dart';
import 'package:k_chart/chart_translations.dart';

extension ChartTranslationsMap on Map<String, ChartTranslations> {
  ChartTranslations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final languageTag = '${locale.languageCode}_${locale.countryCode}';

    return this[languageTag] ?? ChartTranslations();
  }
}

extension NumExt on num? {
  bool get notNullOrZero {
    if (this == null || this == 0) {
      return false;
    }
    return this!.abs().toStringAsFixed(4) != "0.0000";
  }
}
