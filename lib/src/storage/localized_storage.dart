import 'dart:async';
import 'package:im_localized/im_localized.dart';

abstract class LocaleStorage {
  Future<void> saveLocale(String value);

  Future<String?> loadLocale();

  Future<void> deleteLocale();
}

abstract class TranslationsStorage {
  Future<void> saveTranslations(Translations translations);

  Future<Translations?> loadTranslations();

  Future<void> deleteTranslations();
}
