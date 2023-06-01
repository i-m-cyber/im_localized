import 'package:intl/intl.dart';
import 'locale_info.dart';
import 'message.dart';
import 'parser.dart';

abstract class Translation {
  const Translation();

  String translate(Map<String, Object?> args);

  static Translation fromMessage(Message message) {
    assert(message.parsedMessages.isNotEmpty);
    final entry = message.parsedMessages.entries.first;
    final locale = entry.key;
    final node = entry.value!;
    return Translation.fromNode(node, locale);
  }

  static Translation fromNode(Node node, LocaleInfo locale) {
    switch (node.type) {
      case ST.string:
        return StaticTranslation.fromNode(node);

      case ST.placeholderExpr:
        return PlaceholderTranslation.fromNode(node);

      case ST.pluralExpr:
        return PluralTranslation.fromNode(node, locale);

      case ST.message:
        final multiTranslation = MultiTranslation.fromNode(node, locale);
        return multiTranslation.translations.length == 1
            ? multiTranslation.translations.first
            : multiTranslation;

      default:
        throw Exception(
          'Localization: Translation.fromNode: '
          'Unknown node type: ${node.type}',
        );
    }
  }
}

class StaticTranslation extends Translation {
  final String _value;

  const StaticTranslation(this._value) : super();

  factory StaticTranslation.fromNode(Node node) =>
      StaticTranslation(node.value!);

  @override
  String translate(Map<String, Object?> args) => _value;

  @override
  String toString() => _value;
}

class PlaceholderTranslation extends Translation {
  final String identifier;

  const PlaceholderTranslation(this.identifier) : super();

  factory PlaceholderTranslation.fromNode(Node node) => PlaceholderTranslation(
      node.children.firstWhere((child) => child.type == ST.identifier).value!);

  @override
  String translate(Map<String, Object?> args) => args[identifier].toString();

  @override
  String toString() => '{$identifier}';
}

class PluralTranslation extends Translation {
  final String identifier;
  final String Function(num) intlTranslator;

  const PluralTranslation(this.identifier, this.intlTranslator) : super();

  factory PluralTranslation.fromNode(Node node, LocaleInfo locale) {
    assert(node.children.where((child) => child.type == ST.plural).length == 1);
    assert(node.children.where((child) => child.type == ST.identifier).length ==
        1);
    assert(
        node.children.where((child) => child.type == ST.pluralParts).length ==
            1);

    final identifier =
        node.children.firstWhere((child) => child.type == ST.identifier).value!;

    final parts =
        node.children.firstWhere((child) => child.type == ST.pluralParts);

    final intlTranslator =
        _addTranslationsFromPluralParts(parts.children, locale);

    return PluralTranslation(identifier, intlTranslator);
  }

  @override
  String translate(Map<String, Object?> args) {
    final value = args[identifier];
    if (value is num) {
      return intlTranslator(value).replaceAll('#', value.toString());
    } else if (value == null) {
      return null.toString();
    } else {
      return Exception(
        'Expected number, got: "$value" of type ${value.runtimeType}',
      ).toString();
    }
  }

  @override
  String toString() => '#{$identifier}';

  static String Function(num) _addTranslationsFromPluralParts(
    List<Node> parts,
    LocaleInfo locale,
  ) {
    assert(parts.every((part) => part.type == ST.pluralPart));

    final translations = <dynamic, String>{};

    for (final part in parts) {
      dynamic identifier;
      dynamic translation;

      for (final partChild in part.children) {
        switch (partChild.type) {
          case ST.identifier:
            identifier = partChild.value;
            break;

          case ST.number:
            identifier = num.parse(partChild.value!);
            break;

          case ST.other:
            identifier = 'other';
            break;

          case ST.message:
            translation = Translation.fromNode(partChild, locale);
            break;

          default:
        }
      }

      identifier = identifier is String ? identifier.toLowerCase() : identifier;

      identifier = {
            0: 'zero',
            1: 'one',
          }[identifier] ??
          identifier;

      if (translation is! StaticTranslation) {
        throw Exception(
          'Localization: PluralTranslation: \n'
          'Only static translations are supported in plural parts.\n'
          'Got ${translation.runtimeType} instead.',
        );
      }

      translations[identifier] = translation._value;
    }

    final zero = translations['zero'];
    final one = translations['one'];
    final few = translations['few'];
    final many = translations['many'];
    final other = translations['other'];

    assert(other is String);

    return (value) => Intl.pluralLogic(
          value,
          zero: zero,
          one: one,
          few: few,
          many: many,
          other: other!,
          locale: locale.toString(),
        );
  }
}

class MultiTranslation extends Translation {
  final List<Translation> translations;

  const MultiTranslation(this.translations) : super();

  factory MultiTranslation.fromNode(Node node, LocaleInfo locale) =>
      MultiTranslation(node.children
          .map((nested) => Translation.fromNode(nested, locale))
          .toList());

  @override
  String translate(Map<String, Object?> args) {
    return translations.map((t) => t.translate(args)).join();
  }

  @override
  String toString() =>
      translations.map((translation) => translation.toString()).join('');
}
