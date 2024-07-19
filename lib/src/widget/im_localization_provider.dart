part of 'im_localized_app.dart';

class _ImLocalizedProvider extends InheritedWidget {
  final ImLocalizedApp parent;
  final ImLocalizedController localizationController;
  final Locale? currentLocale;
  final _ImLocalizationDelegate delegate;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// ```dart
  ///   delegates = [
  ///     delegate,
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate,
  ///   ],
  /// ```
  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  // _ImLocalizationDelegate get delegate => parent.delegate;

  _ImLocalizedProvider(
    this.parent,
    this.localizationController, {
    required this.delegate,
  })  : currentLocale = localizationController.locale,
        super(
            child:
                localizationController.initialized ? parent.app : _loaderApp) {
    ImLocalizedApp.logger.d('Init provider');
    localizationController.updateListener();
  }

  /// Get current locale
  Locale get locale => localizationController.locale;

  /// Get fallback locale
  List<Locale> get fallbackLocales => parent.fallbackLocales;
  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != localizationController.locale) {
      assert(parent.supportedLocales.contains(locale));
      await localizationController.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  Future<void> deleteSavedLocale() async {
    await localizationController.deleteSavedLocale();
  }

  /// Getting device locale from platform
  Locale get deviceLocale => localizationController.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => localizationController.resetLocale();

  /// Sets new translations and saves it to storage if translationsStorage
  /// is not null
  Future<void> injectTranslations(
          List<Map<LocalizationKey, LocalizationValue>> next) =>
      localizationController.injectTranslations(next);

  @override
  bool updateShouldNotify(_ImLocalizedProvider oldWidget) {
    return true;
    // return oldWidget.currentLocale != locale;
  }

  // Gets closest instance of this class that encloses the given context
  static _ImLocalizedProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ImLocalizedProvider>();
}

const _loaderApp = Material(
  child: Center(
    child: CircularProgressIndicator(),
  ),
);
