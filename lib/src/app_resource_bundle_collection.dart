// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'locale_info.dart';
import 'app_resource_bundle.dart';
import 'exceptions.dart';

// Represents all of the ARB files in [directory] as [AppResourceBundle]s.
class AppResourceBundleCollection {
  factory AppResourceBundleCollection(Map dictionaries) {
    final Map<String, List<LocaleInfo>> languageToLocales =
        <String, List<LocaleInfo>>{};

    final localeToBundle = <LocaleInfo, AppResourceBundle>{};

    for (final json in dictionaries.values) {
      final AppResourceBundle bundle = AppResourceBundle(json);
      localeToBundle[bundle.locale] = bundle;
      languageToLocales[bundle.locale.languageCode] ??= <LocaleInfo>[];
      languageToLocales[bundle.locale.languageCode]!.add(bundle.locale);
    }

    languageToLocales.forEach(
      (String language, List<LocaleInfo> listOfCorrespondingLocales) {
        final List<String> localeStrings =
            listOfCorrespondingLocales.map((LocaleInfo locale) {
          return locale.toString();
        }).toList();
        if (!localeStrings.contains(language)) {
          throw L10nException(
              'JSON localization for a fallback, $language, does not exist, even though \n'
              'the following locale(s) exist: $listOfCorrespondingLocales. \n'
              'When locales specify a script code or country code, a \n'
              'base locale (without the script code or country code) should \n'
              'exist as the fallback.');
        }
      },
    );

    return AppResourceBundleCollection._(localeToBundle, languageToLocales);
  }

  const AppResourceBundleCollection._(
      this._localeToBundle, this._languageToLocales);

  final Map<LocaleInfo, AppResourceBundle> _localeToBundle;
  final Map<String, List<LocaleInfo>> _languageToLocales;

  Iterable<LocaleInfo> get locales => _localeToBundle.keys;
  Iterable<AppResourceBundle> get bundles => _localeToBundle.values;
  AppResourceBundle? bundleFor(LocaleInfo locale) => _localeToBundle[locale];

  Iterable<String> get languages => _languageToLocales.keys;
  Iterable<LocaleInfo> localesForLanguage(String language) =>
      _languageToLocales[language] ?? <LocaleInfo>[];

  @override
  String toString() {
    return 'AppResourceBundleCollection(${locales.length} locales)';
  }
}
