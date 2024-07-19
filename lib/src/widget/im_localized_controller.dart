import 'dart:async';

import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';
import 'package:im_localized/src/utils/select_locale.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:im_localized/src/utils/utils.dart';

class ImLocalizedController extends ChangeNotifier {
  final List<Locale> fallbackLocales;

  final LocaleStorage? localeStorage;

  final TranslationsStorage? translationsStorage;

  ImLocalizedController({
    required List<Locale> supportedLocales,
    this.localeStorage,
    this.translationsStorage,
    Translations? translations,
    Locale? startLocale,
    this.fallbackLocales = const [],
  }) {
    if (translations != null) {
      _setTranslations(translations);
    }
    _init(supportedLocales);
  }

  Locale? _savedLocale;

  bool _initializing = false;

  late Locale _deviceLocale;

  Locale? _locale;

  Translations? _translations;

  Translations? _fallbackTranslations;

  //******************************************/
  //    Getters & Setters
  //******************************************/

  Translations? get translations => _translations;

  Translations? get fallbackTranslations => _fallbackTranslations;

  bool get initializing => _initializing;

  bool get initialized => _locale != null;

  Locale get deviceLocale => _deviceLocale;

  Locale? get savedLocale => _savedLocale;

  Locale get locale => _locale ?? const Locale('und');

  void _setTranslations(Translations next) {
    _translations = next;
    Translations.UNSAFE_setInstanceGetter(() => _translations!);
  }

  //******************************************/
  //    Methods
  //******************************************/

  /// sets new locale and saves it to storage if localeStorage is not null
  Future<void> setLocale(Locale nextLocale, {saveToStorage = true}) async {
    if (!initialized) {
      throw Exception('ImLocalizedController.setLocale: '
          'Locale not initialized yet');
    }

    _locale = nextLocale;
    _setTranslations(_translations!.copyWith(activeLocale: _locale));
    notifyListeners();
    ImLocalizedApp.logger.d('Locale $locale changed');
    if (saveToStorage && localeStorage != null) {
      await localeStorage!.saveLocale(_locale!.toString());
      ImLocalizedApp.logger.d('Locale $locale saved');
    }
  }

  /// removes saved locale from storage, but does not change the current locale
  Future<void> deleteSavedLocale() async {
    if (!initialized) {
      throw Exception('ImLocalizedController.deleteSavedLocale: '
          'Locale not initialized yet');
    }

    _savedLocale = null;
    if (localeStorage != null) {
      await localeStorage!.deleteLocale();
    }
  }

  /// removes saved locale from storage and sets locale to device locale
  Future<void> resetLocale() async {
    if (!initialized) {
      throw Exception('ImLocalizedController.resetLocale: '
          'Locale not initialized yet');
    }

    ImLocalizedApp.logger.d('Reset locale to platform locale $_deviceLocale');
    await setLocale(_deviceLocale, saveToStorage: false);
    if (localeStorage != null) {
      await localeStorage!.deleteLocale();
    }
  }

  /// Sets new translations and saves it to storage if translationsStorage
  /// is not null
  Future<void> injectTranslations(
    List<Map<LocalizationKey, LocalizationValue>> next, {
    bool updateListener = true,
  }) async {
    final nextTranslations =
        Translations.fromList(next, activeLocale: _translations?.activeLocale);

    _setTranslations(nextTranslations);
    if (updateListener) notifyListeners();
    if (translationsStorage != null) {
      return translationsStorage!.saveTranslations(_translations!);
    }
  }

  Future<void> setTranslations(
    Translations next, {
    bool updateListener = true,
  }) async {
    _setTranslations(next);
    if (updateListener) notifyListeners();
    if (translationsStorage != null) {
      return translationsStorage!.saveTranslations(_translations!);
    }
  }

  void updateListener() {
    notifyListeners();
  }

  //******************************************/
  //    private
  //******************************************/

  Future<void> _init(
    List<Locale> supportedLocales, {
    Locale? startLocale,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    _initializing = true;

    await Future.wait([
      // get deviceLocale
      findSystemLocale().then((value) {
        _deviceLocale = value.toLocale();
      }),
      // get saved locale if localeStorage is not null
      if (localeStorage != null)
        localeStorage!.loadLocale().then((localeString) {
          _savedLocale = localeString?.toLocale();
        }),
      // get translations if translationsStorage is not null
      if (translationsStorage != null)
        translationsStorage!.loadTranslations().then((translations) {
          if (translations != null) {
            _setTranslations(translations);
          }
        }),
    ]);

    _locale = selectLocale(
      supportedLocales,
      _savedLocale ?? startLocale ?? deviceLocale,
      fallbackLocales: fallbackLocales,
    );

    _initializing = false;

    assert(initialized);

    setLocale(_locale!, saveToStorage: false);

    notifyListeners();

    ImLocalizedApp.logger.d('Localization initialized');
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
