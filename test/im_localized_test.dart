import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:im_localized/im_localized.dart';

import '../bin/generate.dart';

void main() {
  test('translates plural in single language app', () {
    final translations = Translations.fromList([
      {
        '@@locale': 'en',
        'unreadMessages': '''Bob and Charlie {
              count,
              plural,
                =0 {have no messages}
                one {have one message}
                few {does not apply to English}
                other {have # unread messages}
            } for {name}''',
      }
    ]);

    expect(
      translations
          .translate('unreadMessages', args: {'count': 0, 'name': 'Ana'}),
      'Bob and Charlie have no messages for Ana',
    );

    expect(
      translations
          .translate('unreadMessages', args: {'count': 1, 'name': 'Ana'}),
      'Bob and Charlie have one message for Ana',
    );

    expect(
      translations
          .translate('unreadMessages', args: {'count': 4, 'name': 'Ana'}),
      'Bob and Charlie have 4 unread messages for Ana',
    );

    expect(
      translations
          .translate('unreadMessages', args: {'count': -1, 'name': 'Ana'}),
      'Bob and Charlie have -1 unread messages for Ana',
    );
  });

  test('translates static string in two-language app', () {
    var translations = Translations.fromList(
      [
        {
          "@@locale": "en",
          "languageFlag": "🇺🇸",
          "hiMessage": "Hi {name}!",
          "increment": "Increment",
          "itemCounter": '''Currently there {
        count,
        plural,
          =0{are no items}
          =1{is one item}
          other{are # items}
      } in this app''',
        },
        {
          "@@locale": "es",
          "languageFlag": "🇪🇸",
          "hiMessage": "¡Hola {name}!",
          "increment": "Incremento",
          "itemCounter": '''Actualmente hay {
        count,
        plural,
          =0{no hay elementos}
          =1{un elemento}
          other{# elementos}
      } en esta aplicación''',
        },
      ],
    );

    expect(translations.translate('languageFlag'), "🇺🇸");

    translations = translations.copyWith(activeLocale: const Locale('es'));

    expect(translations.translate('languageFlag'), "🇪🇸");
  });

  test('can parse .jsonc file', () async {
    final json = await readJsonFile('./test/en.jsonc');
    expect(json['@@locale'], 'en');
  });
}
