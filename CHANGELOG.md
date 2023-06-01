## 0.0.5

* Display key instead of "" when using key unsupported by LocaleKeys
* Set Translations.instance getter on every ImLocalizedController.translations change
* Rename replaceTranslations to injectTranslations

## 0.0.4

* Added default delegates from flutter_localizations library
  * GlobalMaterialLocalizations.delegate
  * GlobalWidgetsLocalizations.delegate
  * GlobalCupertinoLocalizations.delegate
* Implemented save locale and translations to device storage
* Added replaceTranslations method that replaces translations in runtime

## 0.0.3

* Added `flutter pub run im_localized:generate` script

## 0.0.2

* Implemented ImLocalizedApp.fromList and locale switching in runtime

## 0.0.1

* Initial unstable release
