import 'dart:convert';
import 'package:intl/locale.dart';

String generateLocalizationFileFromJsonList(
  List localizations,
) {
  final mapByLocale = localizations.fold<Map<Locale, Map<String, String>>>(
    {},
    (acc, cur) {
      if (cur['@@locale'] == null) {
        throw Exception('Missing @@locale key in translation file');
      }
      final locale = Locale.parse(cur['@@locale']!);
      acc[locale] = (cur as Map).cast<String, String>();
      return acc;
    },
  );

  return generateLocalizationFileFromMap(mapByLocale);
}

String generateLocalizationFileFromMap(
  Map<Locale, Map<String, String>> localizations,
) {
  final allKeys = localizations.values
      .map((e) => e.keys)
      .expand((e) => e)
      .toSet()
      .where((key) => !key.startsWith('@@'))
      .toList()
    ..sort();

  final sorted = localizations.entries.toList()
    ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

  String includeTranslation(Map<String, String> translation) {
    return '  {\n${translation.entries.map((entry) => '    ${entry.key.startsWith('@@') ? '"${entry.key}"' : 'LocaleKeys.${entry.key}'}: ${jsonEncode(entry.value)},').join('\n')}\n  },';
  }

  return '''
// DO NOT EDIT. This is code generated via package:im_localized/generate.dart'
// to regenerate run `flutter pub run im_localized:generate`'

// ignore_for_file: constant_identifier_names, prefer_single_quotes

export 'package:im_localized/im_localized.dart';

abstract class LocaleKeys {
${allKeys.map((key) => "  static const $key = '$key';").join('\n')}
}

final initialTranslations = [
${sorted.map((entry) {
    /// if do not have all kezs add it as key:key
    final translation = entry.value;
    for (var key in allKeys) {
      if (!translation.containsKey(key)) {
        ///ignore: avoid_print
        print(
            '⚠️ Missing key: $key in ${entry.key}! Key added with value: $key');
        translation[key] = key;
      }
    }
    return includeTranslation(translation);
  }).join('\n')}
];
''';
}
