import 'dart:async';

import 'package:im_localized/im_localized.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocaleStorage implements LocaleStorage {
  final String storageKey;

  SharedPreferencesLocaleStorage([this.storageKey = 'locale']);

  @override
  Future<void> saveLocale(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, value);
  }

  @override
  Future<String?> loadLocale() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(storageKey);
  }

  @override
  Future<void> deleteLocale() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}

class SharedPreferencesTranslationsStorage implements TranslationsStorage {
  final String storageKey;

  SharedPreferencesTranslationsStorage([this.storageKey = 'translations']);

  @override
  Future<void> saveTranslations(Translations translations) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, translations.toJson());
  }

  @override
  Future<Translations?> loadTranslations() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(storageKey);
    return source == null ? null : Translations.maybeFromJson(source);
  }

  @override
  Future<void> deleteTranslations() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
