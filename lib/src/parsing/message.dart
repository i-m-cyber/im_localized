// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'app_resource_bundle_collection.dart';
import 'app_resource_bundle.dart';
import 'exceptions.dart';
import 'locale_info.dart';
import 'parser.dart';
import 'placeholder.dart';

// All translations for a given message specified by a resource id.
//
// The template ARB file must contain an entry called @myResourceId for each
// message named myResourceId. The @ entry describes message parameters
// called "placeholders" and can include an optional description.
// Here's a simple example message with no parameters:
//
// "helloWorld": "Hello World",
// "@helloWorld": {
//   "description": "The conventional newborn programmer greeting"
// }
//
// The value of this Message is "Hello World". The Message's value is the
// localized string to be shown for the template ARB file's locale.
// The docs for the Placeholder explain how placeholder entries are defined.

class Message {
  Message({
    required AppResourceBundle templateBundle,
    required AppResourceBundleCollection allBundles,
    required this.resourceId,
    required bool isResourceAttributeRequired,
    this.useEscaping = false,
  })  : assert(resourceId.isNotEmpty),
        value = templateBundle.translationFor(resourceId) ?? '',
        description = _description(
            templateBundle.resources, resourceId, isResourceAttributeRequired),
        placeholders = _placeholders(
            templateBundle.resources, resourceId, isResourceAttributeRequired),
        messages = <LocaleInfo, String?>{},
        parsedMessages = <LocaleInfo, Node?>{} {
    // Collect all translations from allBundles and parse them.
    for (final LocaleInfo locale in allBundles.locales) {
      final AppResourceBundle? bundle = allBundles.bundleFor(locale);
      if (bundle != null) {
        final String? translation = bundle.translationFor(resourceId);
        messages[locale] = translation;
        try {
          parsedMessages[locale] = translation == null
              ? null
              : Parser(resourceId, locale.toString(), translation,
                      useEscaping: useEscaping)
                  .parse();
        } on L10nParserException catch (_) {
          // Treat it as an untranslated message in case we can't parse.
          parsedMessages[locale] = null;
          hadErrors = true;
          rethrow;
        }
      }
    }
    // Infer the placeholders
    _inferPlaceholders();
  }

  final String resourceId;
  final String value;
  final String? description;
  late final Map<LocaleInfo, String?> messages;
  final Map<LocaleInfo, Node?> parsedMessages;
  final Map<String, Placeholder> placeholders;
  final bool useEscaping;
  bool hadErrors = false;

  bool get placeholdersRequireFormatting =>
      placeholders.values.any((Placeholder p) => p.requiresFormatting);

  // static String _value(Map<String, Object?> bundle, String resourceId) {
  //   final Object? value = bundle[resourceId];
  //   if (value == null) {
  //     throw L10nException('A value for resource "$resourceId" was not found.');
  //   }
  //   if (value is! String) {
  //     throw L10nException('The value of "$resourceId" is not a string.');
  //   }
  //   return value;
  // }

  static Map<String, Object?>? _attributes(
    Map<String, Object?> bundle,
    String resourceId,
    bool isResourceAttributeRequired,
  ) {
    final Object? attributes = bundle['@$resourceId'];
    if (isResourceAttributeRequired) {
      if (attributes == null) {
        throw L10nException(
            'Resource attribute "@$resourceId" was not found. Please '
            'ensure that each resource has a corresponding @resource.');
      }
    }

    if (attributes != null && attributes is! Map<String, Object?>) {
      throw L10nException(
          'The resource attribute "@$resourceId" is not a properly formatted Map. '
          'Ensure that it is a map with keys that are strings.');
    }

    return attributes as Map<String, Object?>?;
  }

  static String? _description(
    Map<String, Object?> bundle,
    String resourceId,
    bool isResourceAttributeRequired,
  ) {
    final Map<String, Object?>? resourceAttributes =
        _attributes(bundle, resourceId, isResourceAttributeRequired);
    if (resourceAttributes == null) {
      return null;
    }

    final Object? value = resourceAttributes['description'];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw L10nException(
          'The description for "@$resourceId" is not a properly formatted String.');
    }
    return value;
  }

  static Map<String, Placeholder> _placeholders(
    Map<String, Object?> bundle,
    String resourceId,
    bool isResourceAttributeRequired,
  ) {
    final Map<String, Object?>? resourceAttributes =
        _attributes(bundle, resourceId, isResourceAttributeRequired);
    if (resourceAttributes == null) {
      return <String, Placeholder>{};
    }
    final Object? allPlaceholdersMap = resourceAttributes['placeholders'];
    if (allPlaceholdersMap == null) {
      return <String, Placeholder>{};
    }
    if (allPlaceholdersMap is! Map<String, Object?>) {
      throw L10nException(
          'The "placeholders" attribute for message $resourceId, is not '
          'properly formatted. Ensure that it is a map with string valued keys.');
    }
    return Map<String, Placeholder>.fromEntries(
      allPlaceholdersMap.keys.map((String placeholderName) {
        final Object? value = allPlaceholdersMap[placeholderName];
        if (value is! Map<String, Object?>) {
          throw L10nException(
              'The value of the "$placeholderName" placeholder attribute for message '
              '"$resourceId", is not properly formatted. Ensure that it is a map '
              'with string valued keys.');
        }
        return MapEntry<String, Placeholder>(
            placeholderName, Placeholder(resourceId, placeholderName, value));
      }),
    );
  }

  // Using parsed translations, attempt to infer types of placeholders used by plurals and selects.
  // For undeclared placeholders, create a new placeholder.
  void _inferPlaceholders() {
    // We keep the undeclared placeholders separate so that we can sort them alphabetically afterwards.
    final Map<String, Placeholder> undeclaredPlaceholders =
        <String, Placeholder>{};
    // Helper for getting placeholder by name.
    Placeholder? getPlaceholder(String name) =>
        placeholders[name] ?? undeclaredPlaceholders[name];
    for (final LocaleInfo locale in parsedMessages.keys) {
      if (parsedMessages[locale] == null) {
        continue;
      }
      final List<Node> traversalStack = <Node>[parsedMessages[locale]!];
      while (traversalStack.isNotEmpty) {
        final Node node = traversalStack.removeLast();
        if (<ST>[ST.placeholderExpr, ST.pluralExpr, ST.selectExpr]
            .contains(node.type)) {
          final String identifier = node.children[1].value!;
          Placeholder? placeholder = getPlaceholder(identifier);
          if (placeholder == null) {
            placeholder =
                Placeholder(resourceId, identifier, <String, Object?>{});
            undeclaredPlaceholders[identifier] = placeholder;
          }
          if (node.type == ST.pluralExpr) {
            placeholder.isPlural = true;
          } else if (node.type == ST.selectExpr) {
            placeholder.isSelect = true;
          }
        }
        traversalStack.addAll(node.children);
      }
    }
    placeholders.addEntries(undeclaredPlaceholders.entries.toList()
      ..sort((MapEntry<String, Placeholder> p1,
              MapEntry<String, Placeholder> p2) =>
          p1.key.compareTo(p2.key)));

    for (final Placeholder placeholder in placeholders.values) {
      if (placeholder.isPlural && placeholder.isSelect) {
        throw L10nException(
            'Placeholder is used as both a plural and select in certain languages.');
      } else if (placeholder.isPlural) {
        if (placeholder.type == null) {
          placeholder.type = 'num';
        } else if (!<String>['num', 'int'].contains(placeholder.type)) {
          throw L10nException(
              "Placeholders used in plurals must be of type 'num' or 'int'");
        }
      } else if (placeholder.isSelect) {
        if (placeholder.type == null) {
          placeholder.type = 'String';
        } else if (placeholder.type != 'String') {
          throw L10nException(
              "Placeholders used in selects must be of type 'String'");
        }
      }
      placeholder.type ??= 'Object';
    }
  }
}
