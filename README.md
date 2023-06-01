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
  WidgetsFlutterBinding.ensureInitialized();
  await ImLocalizedApp.ensureInitialized();

  runApp(
    ImLocalizedApp.fromList(
      app: const MyApp(),
      initialTranslations: initialTranslations,

      /// uncomment following line to save locale changes to local storage
      // localeStorage: SharedPreferencesLocaleStorage(),

      /// uncomment following line to save injected translations to local storage
      // translationsStorage: SharedPreferencesTranslationsStorage(),
    ),
  );
}
```

## Acknowledgments

This library uses source code from the following projects:

- [easy_localization](https://pub.dev/packages/easy_localization) by [github.com/aissat/](https://github.com/aissat/)
- [flutter_tools](https://github.com/flutter/flutter/tree/master/packages/flutter_tools) from the Flutter team

## Additional information

Work in progress

## License

[LICENSE](LICENSE)
