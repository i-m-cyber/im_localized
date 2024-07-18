# Change Log

## 0.0.14

* rebuild on translations change
* example update

## 0.0.13

* missing keys fix
* generator fix to add all keys to all languages

## 0.0.12

* flutter 3.22 support, startLocale fixed

## 0.0.11

* extract generateLocalizationFileFromJsonList and generateLocalizationFileFromMap to separate file to make it available for library users

## 0.0.10

* add "export 'package:im_localized/im_localized.dart';" to generated localization.dart file

## 0.0.9

* add support for .jsonc files

## 0.0.8

* add interpolation support for inline strings'

## 0.0.7

* add generating from json instructions to README

## 0.0.6

* Add support for platforms other than **web** to pubspec.yaml

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
