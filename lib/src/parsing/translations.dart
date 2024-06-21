import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';
import 'package:im_localized/src/parsing/app_resource_bundle.dart';
import 'package:im_localized/src/utils/utils.dart';

import 'app_resource_bundle_collection.dart';
import 'message.dart';
import 'translation.dart';

typedef LocalizationKey = String;
typedef LocalizationValue = String;

class Translations {
  final Map<Locale, Map<LocalizationKey, LocalizationValue>> _localizationData;
  late final Locale activeLocale;
  late final AppResourceBundleCollection _bundles;
  late final Map<LocalizationKey, Map<Locale, Translation>> _translations;

  Translations._({
    required AppResourceBundleCollection bundles,
    required Map<Locale, Map<LocalizationKey, LocalizationValue>>
        localizationData,
    required Map<LocalizationKey, Map<Locale, Translation>> translations,
    required Locale activeLocale,
  })  : activeLocale = bundles.bundles
                .any((bundle) => bundle.locale.toLocale() == activeLocale)
            ? activeLocale
            : bundles.bundles.first.locale.toLocale(),
        _localizationData = localizationData,
        _bundles = bundles,
        _translations = translations;

  factory Translations.fromMap(
    Map<Locale, Map<LocalizationKey, LocalizationValue>> localizationData, {
    Locale? activeLocale,
  }) {
    final bundleCollection = AppResourceBundleCollection(localizationData);
    final translations = <String, Map<Locale, Translation>>{};
    AppResourceBundle? bundle = bundleCollection.bundles.first;
    for (final tmp in bundleCollection.bundles) {
      bundle = bundle?.merge(tmp);
    }
    bundle ??= bundleCollection.bundles.first;

    for (final resourceId in bundle.resourceIds) {
      final message = Message(
        templateBundle: bundle,
        allBundles: bundleCollection,
        resourceId: resourceId,
        isResourceAttributeRequired: false,
        useEscaping: false,
      );

      for (final messageEntry in message.parsedMessages.entries) {
        final locale = messageEntry.key;
        final node = messageEntry.value;

        if (node == null) {
          continue;
        }

        final translation = Translation.fromNode(node, locale);

        translations.update(
          resourceId,
          (existing) => existing..addAll({locale.toLocale(): translation}),
          ifAbsent: () => {locale.toLocale(): translation},
        );
      }
    }

    return Translations._(
      bundles: bundleCollection,
      localizationData: localizationData,
      translations: translations,
      activeLocale:
          activeLocale ?? bundleCollection.bundles.first.locale.toLocale(),
    );
  }

  factory Translations.fromList(
    List<Map<LocalizationKey, LocalizationValue>> list, {
    Locale? activeLocale,
  }) {
    assert(
      list.every((element) => element.containsKey('@@locale')),
    );

    final map = <Locale, Map<String, String>>{
      for (var localization in list)
        parseLocale(localization['@@locale']!): localization,
    };

    return Translations.fromMap(map, activeLocale: activeLocale);
  }

  factory Translations.fromPhrase(
    String phrase, {
    String key = 'default',
    String locale = 'und',
  }) {
    return Translations.fromList([
      {
        '@@locale': locale,
        key: phrase,
      }
    ]);
  }

  static Translations Function()? _instanceGetter;

  static Translations get instance => _instanceGetter == null
      ? throw Exception('ImLocalizations not initialized')
      : _instanceGetter!();

  // ignore: non_constant_identifier_names
  static UNSAFE_setInstanceGetter(Translations Function()? next) {
    _instanceGetter = next;
  }

  static Translations? maybeFromJson(String json) {
    try {
      final jsonList = (jsonDecode(json) as List)
          .map((m) => (m as Map).cast<LocalizationKey, LocalizationValue>())
          .toList();

      return Translations.fromList(jsonList);
    } catch (e) {
      return null;
    }
  }

  String toJson() {
    final jsonList = _localizationData.entries
        .map((entry) => entry.value.containsKey('@@locale')
            ? entry.value
            : {
                ...entry.value,
                '@@locale': entry.key.toString(),
              })
        .toList();
    return jsonEncode(jsonList);
  }

  Translations copyWith({Locale? activeLocale}) {
    return Translations._(
      bundles: _bundles,
      localizationData: _localizationData,
      translations: _translations,
      activeLocale: activeLocale ?? this.activeLocale,
    );
  }

  List<Locale> get supportedLocales => _localizationData.keys.toList();

  bool exists(String resourceId) => _translations.containsKey(resourceId);

  String? maybeTranslate(
    LocalizationKey resourceId, {
    Map<String, Object?>? args,
    Locale? locale,
  }) {
    final translationEntries = _translations[resourceId]?.entries;

    if (translationEntries == null) {
      return Translations.fromPhrase(resourceId, key: 'default').maybeTranslate(
        'default',
        args: args,
      );
    }

    final match = translationEntries.firstWhereOrNull(
      (translationEntry) =>
          translationEntry.key.supports(locale ?? activeLocale),
      // orElse: () => translationEntries.first,
    );
    if (match == null) {
      return resourceId;
    }
    return match.value.translate(args ?? const {});
  }

  String translate(
    LocalizationKey resourceId, {
    Map<String, Object?>? args,
    Locale? locale,
  }) =>
      maybeTranslate(resourceId, args: args, locale: locale) ?? '';
}
