import 'package:intl/locale.dart';

import 'app_resource_bundle_collection.dart';
import 'message.dart';
import 'translation.dart';

typedef LocalizationKey = String;
typedef LocalizationValue = String;

class LocalizationGenerator {
  final Map<Locale, Map<LocalizationKey, LocalizationValue>> _localizationData;
  late final AppResourceBundleCollection _bundles;
  late final Map<LocalizationKey, Map<Locale, Translation>> _translations;

  LocalizationGenerator(this._localizationData) {
    _bundles = AppResourceBundleCollection(_localizationData);
    _translations = {};
    for (final bundle in _bundles.bundles) {
      for (final resourceId in bundle.resourceIds) {
        final message = Message(
          templateBundle: bundle,
          allBundles: _bundles,
          resourceId: resourceId,
          isResourceAttributeRequired: false,
          useEscaping: false,
        );

        final translation = Translation.fromMessage(message);

        _translations.update(
          resourceId,
          (existing) =>
              existing..addAll({bundle.locale.toLocale(): translation}),
          ifAbsent: () => {bundle.locale.toLocale(): translation},
        );
      }
    }
  }

  String? maybeTranslate(
    LocalizationKey resourceId, [
    Map<String, Object?>? args,
  ]) {
    return _translations[resourceId]
        ?.values
        .firstOrNull
        ?.translate(args ?? const {});
  }

  String translate(
    LocalizationKey resourceId, [
    Map<String, Object?>? args,
  ]) =>
      maybeTranslate(resourceId, args) ?? '';
}
