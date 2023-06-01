import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';
import 'package:im_localized/src/utils/utils.dart';

extension LocaleParse on Locale {
  static Locale? tryParse(String localeIdentifier) =>
      tryParseLocale(localeIdentifier);

  static Locale parse(String localeIdentifier) => parseLocale(localeIdentifier);
}

extension StringTranslateExtension on String {
  String translate({Map<String, Object?>? args, Locale? locale}) =>
      _translate(this, args: args, locale: locale);

  bool translationExists() => _translationExists(this);
}

String _translate(String key, {Map<String, Object?>? args, Locale? locale}) {
  return Translations.instance.translate(key, args: args, locale: locale);
}

bool _translationExists(String key) {
  return Translations.instance.exists(key);
}

/// BuildContext extension method for access to [locale], [supportedLocales], [fallbackLocale], [delegates] and [deleteSavedLocale()]
///
/// Example :
///
/// ```dart
/// context.locale = Locale('en', 'US');
/// print(context.locale.toString());
///
/// context.deleteSavedLocale();
///
/// print(context.supportedLocales); // output: [en_US, ar_DZ, de_DE, ru_RU]
/// print(context.fallbackLocale);   // output: en_US
/// ```
extension BuildContextEasyLocalizationExtension on BuildContext {
  /// Get current locale
  Locale get locale => ImLocalizedApp.of(this)!.locale;

  /// Change app locale
  Future<void> setLocale(Locale val) async =>
      ImLocalizedApp.of(this)!.setLocale(val);

  /// Get List of supported locales.
  List<Locale> get supportedLocales =>
      ImLocalizedApp.of(this)!.supportedLocales;

  /// Get fallback locale
  Locale? get fallbackLocale => ImLocalizedApp.of(this)!.fallbackLocale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  /// return
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get localizationDelegates =>
      ImLocalizedApp.of(this)!.delegates;

  /// Clears a saved locale from device storage
  Future<void> deleteSavedLocale() =>
      ImLocalizedApp.of(this)!.deleteSavedLocale();

  /// Getting device locale from platform
  Locale get deviceLocale => ImLocalizedApp.of(this)!.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => ImLocalizedApp.of(this)!.resetLocale();

  /// An extension method for translating your language keys.
  /// Subscribes the widget on current [Localization] that provided from context.
  /// Throws exception if [Localization] was not found.
  ///
  /// [key] Localization key
  /// [args] List of localized strings. Replaces {} left to right
  /// [namedArgs] Map of localized strings. Replaces the name keys {key_name} according to its name
  /// [gender] Gender switcher. Changes the localized string based on gender string
  ///
  /// Example:
  ///
  /// ```json
  /// {
  ///    "msg":"{} are written in the {} language",
  ///    "msg_named":"Easy localization is written in the {lang} language",
  ///    "msg_mixed":"{} are written in the {lang} language",
  ///    "gender":{
  ///       "male":"Hi man ;) {}",
  ///       "female":"Hello girl :) {}",
  ///       "other":"Hello {}"
  ///    }
  /// }
  /// ```
  /// ```dart
  /// Text(context.tr('msg', args: ['Easy localization', 'Dart']), // args
  /// Text(context.tr('msg_named', namedArgs: {'lang': 'Dart'}),   // namedArgs
  /// Text(context.tr('msg_mixed', args: ['Easy localization'], namedArgs: {'lang': 'Dart'}), // args and namedArgs
  /// Text(context.tr('gender', gender: _gender ? "female" : "male"), // gender
  /// ```
  // String tr(
  //   String key, {
  //   List<String>? args,
  //   Map<String, String>? namedArgs,
  //   String? gender,
  // }) {
  //   final localization = ImLocalization.of(this);

  //   if (localization == null) {
  //     throw const LocalizationNotFoundException();
  //   }

  //   return localization.tr(
  //     key,
  //     args: args,
  //     namedArgs: namedArgs,
  //     gender: gender,
  //   );
  // }
}
