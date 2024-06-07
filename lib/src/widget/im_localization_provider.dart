part of 'im_localized_app.dart';

class _ImLocalizedProvider extends InheritedWidget {
  final ImLocalizedApp parent;
  final ImLocalizedController _controller;
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
    this._controller, {
    required this.delegate,
  })  : currentLocale = _controller.locale,
        super(
            child: _controller.initialized ? parent.app : _loaderApp) {
    ImLocalizedApp.logger.d('Init provider');
  }

  /// Get current locale
  Locale get locale => _controller.locale;

  /// Get fallback locale
  List<Locale> get fallbackLocales => parent.fallbackLocales;
  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _controller.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _controller.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  Future<void> deleteSavedLocale() async {
    await _controller.deleteSavedLocale();
  }

  /// Getting device locale from platform
  Locale get deviceLocale => _controller.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _controller.resetLocale();

  /// Sets new translations and saves it to storage if translationsStorage
  /// is not null
  Future<void> injectTranslations(
          List<Map<LocalizationKey, LocalizationValue>> next) =>
      _controller.injectTranslations(next);

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
