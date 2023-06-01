import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';

Locale selectLocale(
  List<Locale> supportedLocales,
  Locale deviceLocale, {
  Locale? fallbackLocale,
}) {
  return supportedLocales.firstWhere(
    (locale) => locale.supports(deviceLocale),
    orElse: () => fallbackLocale ?? supportedLocales.first,
  );
}
