import 'dart:async';

import 'package:flutter/widgets.dart';
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
///      ImLocalizedApp(
///        child: MyApp(),
///        supportedLocales: [Locale('en', 'US'), Locale('es', 'ES')],
///      )
///    );
///  }
///  ```
class ImLocalizedApp extends StatefulWidget {
  /// Place for your main page widget.
  final Widget app;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale? fallbackLocale;

  /// Overrides device locale.
  final Locale? startLocale;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslations: true
  /// ```
  final bool useFallbackTranslations;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  final Translations? _initialTranslations;

  ImLocalizedApp._({
    super.key,
    required this.app,
    required this.supportedLocales,
    Translations? initialTranslations,
    this.fallbackLocale,
    this.startLocale,
    this.useFallbackTranslations = false,
    this.saveLocale = true,
  }) : _initialTranslations = initialTranslations {
    assert(supportedLocales.isNotEmpty);
    ImLocalizedApp.logger.d('Start');
  }

  factory ImLocalizedApp.fromList({
    Key? key,
    required Widget app,
    required List<Map<String, String>> initialTranslations,
    Locale? fallbackLocale,
    Locale? startLocale,
    bool useFallbackTranslations = false,
    bool saveLocale = true,
  }) {
    assert(initialTranslations.isNotEmpty);

    final translations = Translations.fromList(initialTranslations);

    return ImLocalizedApp._(
      key: key,
      app: app,
      fallbackLocale: fallbackLocale,
      initialTranslations: translations,
      saveLocale: saveLocale,
      startLocale: startLocale,
      supportedLocales: translations.supportedLocales,
      useFallbackTranslations: useFallbackTranslations,
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _ImLocalizedAppState createState() => _ImLocalizedAppState();

  // ignore: library_private_types_in_public_api
  static _ImLocalizedProvider? of(BuildContext context) =>
      _ImLocalizedProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static Future<void> ensureInitialized() async =>
      await ImLocalizedController.init();

  /// Customizable logger
  static Logger logger = Logger(level: Level.nothing);
}

class _ImLocalizedAppState extends State<ImLocalizedApp> {
  _ImLocalizationDelegate? delegate;
  ImLocalizedController? localizationController;

  @override
  void initState() {
    ImLocalizedApp.logger.d('Init state');
    localizationController = ImLocalizedController(
      fallbackLocale: widget.fallbackLocale,
      translations: widget._initialTranslations,
      saveLocale: widget.saveLocale,
      startLocale: widget.startLocale,
      supportedLocales: widget.supportedLocales,
      useFallbackTranslations: widget.useFallbackTranslations,
    );
    // causes localization to rebuild with new language
    localizationController!.addListener(() {
      if (mounted) setState(() {});
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
