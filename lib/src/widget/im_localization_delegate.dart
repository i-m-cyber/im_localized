part of 'im_localized_app.dart';

class _ImLocalizationDelegate extends LocalizationsDelegate<Localizations> {
  final List<Locale>? supportedLocales;
  final ImLocalizedController? localizationController;

  _ImLocalizationDelegate({
    this.localizationController,
    this.supportedLocales,
  }) {
    ImLocalizedApp.logger.d('Init Localization Delegate');
  }

  @override
  Future<Localizations> load(Locale locale) {
    // TODO: implement load
    throw UnimplementedError('_ImLocalizationDelegate.load');
  }

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  bool shouldReload(LocalizationsDelegate<Localizations> old) => false;
}
