// Represents the contents of one ARB file.
import 'dart:convert';

import 'package:intl/locale.dart';

import 'exceptions.dart';
import 'locale_info.dart';

class AppResourceBundle {
  final LocaleInfo locale;

  /// JSON representation of the contents of the ARB file.
  final Map<String, Object?> resources;
  final Iterable<String> resourceIds;

  factory AppResourceBundle(Map<String, Object?> json) {
    Map<String, Object?> resources = json;

    var localeString = resources['@@locale'] as String?;

    final Locale? parserResult = Locale.tryParse(localeString ?? '');

    if (parserResult != null &&
        _iso639Languages.contains(parserResult.languageCode)) {
      // The parsed result uses dashes ('-'), but we want underscores ('_').
      final String parserLocaleString =
          parserResult.toString().replaceAll('-', '_');

      if (localeString == null) {
        // If @@locale was not defined, use the filename locale suffix.
        localeString = parserLocaleString;
      } else {
        // If the localeString was defined in @@locale and in the filename, verify to
        // see if the parsed locale matches, throw an error if it does not. This
        // prevents developers from confusing issues when both @@locale and
        // "_{locale}" is specified in the filename.
        if (localeString != parserLocaleString) {
          throw L10nException(
              'The locale specified in @@locale and the arb filename do not match. \n'
              'Please make sure that they match, since this prevents any confusion \n'
              'with which locale to use. Otherwise, specify the locale in either the \n'
              'filename of the @@locale key only.\n'
              'Current @@locale value: $localeString\n'
              'Current filename extension: $parserLocaleString');
        }
      }
    }

    if (localeString == null) {
      throw L10nException(
          "The following JSON's locale could not be determined: \n"
          '${jsonEncode(json)} \n'
          "Make sure that the locale is specified in the file's '@@locale'");
    }

    final Iterable<String> ids =
        resources.keys.where((String key) => !key.startsWith('@'));

    return AppResourceBundle._(
      LocaleInfo.fromString(localeString),
      resources,
      ids,
    );
  }

  const AppResourceBundle._(this.locale, this.resources, this.resourceIds);

  factory AppResourceBundle.fromData(
    LocaleInfo locale,
    Map<String, Object?> resources,
  ) {
    final Iterable<String> ids =
        resources.keys.where((String key) => !key.startsWith('@'));
    return AppResourceBundle._(locale, resources, ids);
  }

  String? translationFor(String resourceId) => resources[resourceId] as String?;

  @override
  String toString() {
    return 'AppResourceBundle($locale)';
  }

  AppResourceBundle merge(AppResourceBundle tmp) {
    if (locale != tmp.locale) {
      final Map<String, Object?> mergedResources = Map<String, Object?>.from(
        resources,
      )..addAll(tmp.resources);

      final Iterable<String> mergedIds = mergedResources.keys
          .where((String key) => !key.startsWith('@'))
          .toSet();

      return AppResourceBundle._(
        locale,
        mergedResources,
        mergedIds,
      );
    }
    return this;
  }
}

// A set containing all the ISO630-1 languages. This list was pulled from https://datahub.io/core/language-codes.
final Set<String> _iso639Languages = <String>{
  'aa',
  'ab',
  'ae',
  'af',
  'ak',
  'am',
  'an',
  'ar',
  'as',
  'av',
  'ay',
  'az',
  'ba',
  'be',
  'bg',
  'bh',
  'bi',
  'bm',
  'bn',
  'bo',
  'br',
  'bs',
  'ca',
  'ce',
  'ch',
  'co',
  'cr',
  'cs',
  'cu',
  'cv',
  'cy',
  'da',
  'de',
  'dv',
  'dz',
  'ee',
  'el',
  'en',
  'eo',
  'es',
  'et',
  'eu',
  'fa',
  'ff',
  'fi',
  'fil',
  'fj',
  'fo',
  'fr',
  'fy',
  'ga',
  'gd',
  'gl',
  'gn',
  'gsw',
  'gu',
  'gv',
  'ha',
  'he',
  'hi',
  'ho',
  'hr',
  'ht',
  'hu',
  'hy',
  'hz',
  'ia',
  'id',
  'ie',
  'ig',
  'ii',
  'ik',
  'io',
  'is',
  'it',
  'iu',
  'ja',
  'jv',
  'ka',
  'kg',
  'ki',
  'kj',
  'kk',
  'kl',
  'km',
  'kn',
  'ko',
  'kr',
  'ks',
  'ku',
  'kv',
  'kw',
  'ky',
  'la',
  'lb',
  'lg',
  'li',
  'ln',
  'lo',
  'lt',
  'lu',
  'lv',
  'mg',
  'mh',
  'mi',
  'mk',
  'ml',
  'mn',
  'mr',
  'ms',
  'mt',
  'my',
  'na',
  'nb',
  'nd',
  'ne',
  'ng',
  'nl',
  'nn',
  'no',
  'nr',
  'nv',
  'ny',
  'oc',
  'oj',
  'om',
  'or',
  'os',
  'pa',
  'pi',
  'pl',
  'ps',
  'pt',
  'qu',
  'rm',
  'rn',
  'ro',
  'ru',
  'rw',
  'sa',
  'sc',
  'sd',
  'se',
  'sg',
  'si',
  'sk',
  'sl',
  'sm',
  'sn',
  'so',
  'sq',
  'sr',
  'ss',
  'st',
  'su',
  'sv',
  'sw',
  'ta',
  'te',
  'tg',
  'th',
  'ti',
  'tk',
  'tl',
  'tn',
  'to',
  'tr',
  'ts',
  'tt',
  'tw',
  'ty',
  'ug',
  'uk',
  'ur',
  'uz',
  've',
  'vi',
  'vo',
  'wa',
  'wo',
  'xh',
  'yi',
  'yo',
  'za',
  'zh',
  'zu',
};
