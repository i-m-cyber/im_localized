import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';
import 'package:im_localized/src/utils/select_locale.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:im_localized/src/utils/utils.dart';

class ImLocalizedController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;

  late Locale _locale;

  final bool useFallbackTranslations;
  final bool saveLocale;
  Translations? _translations;
  Translations? _fallbackTranslations;
  Translations? get translations => _translations;
  Translations? get fallbackTranslations => _fallbackTranslations;

  ImLocalizedController({
    required List<Locale> supportedLocales,
    required this.useFallbackTranslations,
    required this.saveLocale,
    Translations? translations,
    Locale? startLocale,
    Locale? fallbackLocale,
    Locale? forceLocale, // used for testing
  }) {
    if (saveLocale && _savedLocale != null) {
      ImLocalizedApp.logger.d('Saved locale loaded ${_savedLocale.toString()}');
      _locale = selectLocale(
        supportedLocales,
        _savedLocale!,
        fallbackLocale: fallbackLocale,
      );
    } else {
      // From Device Locale
      _locale = selectLocale(
        supportedLocales,
        _deviceLocale,
        fallbackLocale: fallbackLocale,
      );
    }

    _translations = translations != null && translations.activeLocale != _locale
        ? translations.copyWith(activeLocale: _locale)
        : _translations;
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale nextLocale) async {
    _locale = nextLocale;
    _translations = _translations?.copyWith(activeLocale: _locale);
    notifyListeners();
    ImLocalizedApp.logger.d('Locale $locale changed');
    await _saveLocale(_locale);
  }

  Future<void> _saveLocale(Locale? locale) async {
    if (!saveLocale) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('locale', locale.toString());
    ImLocalizedApp.logger.d('Locale $locale saved');
  }

  static Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    final strLocale = preferences.getString('locale');
    _savedLocale = strLocale?.toLocale();
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();
    ImLocalizedApp.logger.d('Localization initialized');
  }

  Future<void> deleteSavedLocale() async {
    _savedLocale = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('locale');
    ImLocalizedApp.logger.d('Saved locale deleted');
  }

  Locale get deviceLocale => _deviceLocale;

  Future<void> resetLocale() async {
    ImLocalizedApp.logger.d('Reset locale to platform locale $_deviceLocale');

    await setLocale(_deviceLocale);
  }
}

@visibleForTesting
extension LocaleExtension on Locale {
  bool supports(Locale locale) {
    if (this == locale) {
      return true;
    }
    if (languageCode != locale.languageCode) {
      return false;
    }
    if (countryCode != null &&
        countryCode!.isNotEmpty &&
        countryCode != locale.countryCode) {
      return false;
    }
    if (scriptCode != null && scriptCode != locale.scriptCode) {
      return false;
    }

    return true;
  }
}
