import 'package:flutter_test/flutter_test.dart';

import 'package:im_localized/im_localized.dart';
import 'package:intl/locale.dart';

void main() {
  test('adds one to input values', () {
    final localization = LocalizationGenerator({
      Locale.parse('en'): {
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
    });

    expect(
      localization.translate('unreadMessages', {'count': 0, 'name': 'Ana'}),
      'Bob and Charlie have no messages for Ana',
    );

    expect(
      localization.translate('unreadMessages', {'count': 1, 'name': 'Ana'}),
      'Bob and Charlie have one message for Ana',
    );

    expect(
      localization.translate('unreadMessages', {'count': 4, 'name': 'Ana'}),
      'Bob and Charlie have 4 unread messages for Ana',
    );

    expect(
      localization.translate('unreadMessages', {'count': -1, 'name': 'Ana'}),
      'Bob and Charlie have -1 unread messages for Ana',
    );
  });
}
