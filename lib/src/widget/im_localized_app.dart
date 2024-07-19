import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:im_localized/im_localized.dart';
import 'package:logger/logger.dart';

part 'im_localization_delegate.dart';
part 'im_localization_provider.dart';

///  ImLocalizedApp
///  example:
///  ```
///  void main(){
///    runApp(
///      ImLocalizedApp.fromList(
///        /// initial translations loaded from RAM
///        initialTranslations: initialTranslations,
///
///        /// save locale changes to local storage
///        // localeStorage: SharedPreferencesLocaleStorage(),
///
///        /// save injected translations to local storage
///        // translationsStorage: SharedPreferencesTranslationsStorage(),
///
///        app: const MyApp(),
///     ),
///   );
///    );
///  }
///  ```
class ImLocalizedApp extends StatefulWidget {
  /// Place for your main page widget.
  final Widget app;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Overrides device's and saved locale
  final Locale? startLocale;

  /// Locale when the locale is not in the list
  final List<Locale> fallbackLocales;

  /// handles loading locale on init and saving locale on change
  final LocaleStorage? localeStorage;

  /// handles loading translations on init and saving translations on change
  final TranslationsStorage? translationsStorage;

  final Translations? _initialTranslations;

  ImLocalizedApp._({
    super.key,
    required this.app,
    required this.supportedLocales,
    Translations? initialTranslations,
    this.fallbackLocales = const [],
    this.startLocale,
    this.localeStorage,
    this.translationsStorage,
  }) : _initialTranslations = initialTranslations {
    assert(supportedLocales.isNotEmpty);
    ImLocalizedApp.logger.d('Start');
  }

  factory ImLocalizedApp.fromList({
    Key? key,
    required Widget app,
    required List<Map<String, String>> initialTranslations,
    Locale? startLocale,
    List<Locale> fallbackLocales = const [],
    LocaleStorage? localeStorage,
    TranslationsStorage? translationsStorage,
  }) {
    assert(initialTranslations.isNotEmpty);

    final translations =
        Translations.fromList(initialTranslations, activeLocale: startLocale);

    return ImLocalizedApp._(
      key: key,
      app: app,
      startLocale: startLocale,
      fallbackLocales: fallbackLocales,
      localeStorage: localeStorage,
      translationsStorage: translationsStorage,
      initialTranslations: translations,
      supportedLocales: translations.supportedLocales,
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _ImLocalizedAppState createState() => _ImLocalizedAppState();

  // ignore: library_private_types_in_public_api
  static _ImLocalizedProvider? of(BuildContext context) =>
      _ImLocalizedProvider.of(context);

  /// logger from package:logger
  static Logger logger = Logger(level: Level.off);
}

class _ImLocalizedAppState extends State<ImLocalizedApp> {
  _ImLocalizationDelegate? delegate;
  ImLocalizedController? localizationController;

  @override
  void initState() {
    ImLocalizedApp.logger.d('Init state');

    localizationController = ImLocalizedController(
      startLocale: widget.startLocale,
      fallbackLocales: widget.fallbackLocales,
      translations: widget._initialTranslations,
      supportedLocales: widget.supportedLocales,
      localeStorage: widget.localeStorage,
      translationsStorage: widget.translationsStorage,
    );

    // rebuild when locale changes or new translations get injected
    localizationController!.addListener(() {
      if (mounted) {
        setState(() {
          localizationController?.setTranslations(
            widget._initialTranslations!.copyWith(
              activeLocale: localizationController?.locale,
            ),
            updateListener: false,
          );
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    localizationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImLocalizedApp.logger.d('Build');

    return _ImLocalizedProvider(
      widget,
      localizationController!,
      delegate: _ImLocalizationDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
      ),
    );
  }
}
