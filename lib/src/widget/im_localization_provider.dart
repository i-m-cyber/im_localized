part of 'im_localized_app.dart';

class _ImLocalizedProvider extends InheritedWidget {
  final ImLocalizedApp parent;
  final ImLocalizedController _localeState;
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
    this._localeState, {
    Key? key,
    required this.delegate,
  })  : currentLocale = _localeState.locale,
        super(key: key, child: parent.app) {
    ImLocalizedApp.logger.d('Init provider');
  }

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale? get fallbackLocale => parent.fallbackLocale;
  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _localeState.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  Future<void> deleteSavedLocale() async {
    await _localeState.deleteSavedLocale();
  }

  /// Getting device locale from platform
  Locale get deviceLocale => _localeState.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _localeState.resetLocale();

  @override
  bool updateShouldNotify(_ImLocalizedProvider oldWidget) {
    return oldWidget.currentLocale != locale;
  }

  static _ImLocalizedProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ImLocalizedProvider>();
}
