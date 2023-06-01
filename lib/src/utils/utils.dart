import 'package:intl/locale.dart' as intl;
import 'package:flutter/widgets.dart';

/// [ImLocalized] locale helper
extension LocaleToStringHelper on Locale {
  /// Convert [locale] to String with custom separator
  String toStringWithSeparator({String separator = '_'}) {
    return toString().split('_').join(separator);
  }
}

/// [ImLocalized] string locale helper
extension StringToLocaleHelper on String {
  /// Convert string to [Locale] object
  Locale toLocale({String separator = '_'}) {
    final localeList = split(separator);
    switch (localeList.length) {
      case 2:
        return localeList.last.length == 4 // scriptCode length is 4
            ? Locale.fromSubtags(
                languageCode: localeList.first,
                scriptCode: localeList.last,
              )
            : Locale(localeList.first, localeList.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last,
        );
      default:
        return Locale(localeList.first);
    }
  }
}

Locale? tryParseLocale(String localeIdentifier) {
  final intlLocale = intl.Locale.tryParse(localeIdentifier);
  return intlLocale == null
      ? null
      : Locale.fromSubtags(
          languageCode: intlLocale.languageCode,
          scriptCode: intlLocale.scriptCode,
          countryCode: intlLocale.countryCode,
        );
}

Locale parseLocale(String localeIdentifier) {
  final parsed = tryParseLocale(localeIdentifier);
  if (parsed == null) {
    throw Exception('Invalid locale identifier: $localeIdentifier');
  }
  return parsed;
}
