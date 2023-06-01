import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';

Locale selectLocale(
  List<Locale> supportedLocales,
  Locale desiredLocale, {
  List<Locale> fallbackLocales = const [],
}) {
  return supportedLocales.firstWhere(
    (locale) => locale.supports(desiredLocale),
    orElse: () => fallbackLocales.firstWhere(
      (fallback) => fallback.supports(desiredLocale),
      orElse: () => supportedLocales.first,
    ),
  );
}
