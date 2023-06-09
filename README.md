# im_localized

Flutter ICU compatible Localization library with support for JSONs, runtime parsing and injecting

## Features

- ICU compatible
- parsing JSONs
- runtime parsing and injecting of localizations

## Getting started

### Installation

```bash
flutter pub add im_localized
```

Or add to your `pubspec.yaml`:

```yaml
dependencies:
  im_localized: <last_version>
```

## Usage

Checkout [example/lib/main.dart](example/lib/main.dart) for complete example.

```dart
void main() async {
  runApp(
    ImLocalizedApp.fromList(
      /// initial translations loaded from RAM
      initialTranslations: initialTranslations,

      /// save locale changes to local storage
      // localeStorage: SharedPreferencesLocaleStorage(),

      /// save injected translations to local storage
      // translationsStorage: SharedPreferencesTranslationsStorage(),

      app: const MyApp(),
    ),
  );
}
```

## Generating initial localizations from JSON or ARB files

1. Create at least one localization file (i.e. lib/l10n/en.json)
2. run generate script `flutter pub run im_localized:generate`

## Acknowledgments

This library uses source code from the following projects:

- [easy_localization](https://pub.dev/packages/easy_localization) by [github.com/aissat/](https://github.com/aissat/)
- [flutter_tools](https://github.com/flutter/flutter/tree/master/packages/flutter_tools) from the Flutter team

## Additional information

Work in progress

## License

[LICENSE](LICENSE)
