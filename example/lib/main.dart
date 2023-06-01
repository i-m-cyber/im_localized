import 'package:flutter/material.dart';

import 'package:im_localized/im_localized.dart';

import 'l10n/localization.dart';

void main() async {
  runApp(
    ImLocalizedApp.fromList(
      /// initial translations loaded from RAM
      initialTranslations: initialTranslations,

      /// save locale changes to local storage
      localeStorage: SharedPreferencesLocaleStorage(),

      /// save injected translations to local storage
      translationsStorage: SharedPreferencesTranslationsStorage(),

      app: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _count = 0;

  void _incrementCounter() {
    setState(() {
      _count++;
    });
  }

  void _injectLanguages() {
    context.injectTranslations(
      [
        {
          "@@locale": "en",
          LocaleKeys.languageFlag: "English",
          LocaleKeys.hiMessage: "Hello {name}!",
          LocaleKeys.itemCounter:
              "{ count, plural, =0{no items} =1{one item} other{there are # items}}",
        },
        {
          "@@locale": "es",
          LocaleKeys.languageFlag: "Spanish",
          LocaleKeys.hiMessage: "¡Buenos días {name}!",
          LocaleKeys.itemCounter:
              "{ count, plural, =0{sin artículos} =1{un artículo} other{hay # artículos}}",
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            LocaleKeys.hiMessage.translate(args: {'name': 'Sara'}),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [_buildLanguageSelector()],
        ),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocaleKeys.itemCounter.translate(args: {'count': _count}),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16) +
                    EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom),
                itemCount: _count,
                itemBuilder: (context, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${index + 1}'),
                  ),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColorLight,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: _injectLanguages,
                  icon: const Icon(Icons.cloud_download),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButton<Locale>(
      value: context.locale,
      onChanged: (Locale? locale) {
        if (locale != null) {
          context.setLocale(locale);
        }
      },
      items: context.supportedLocales
          .map<DropdownMenuItem<Locale>>((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(LocaleKeys.languageFlag.translate(locale: locale)),
        );
      }).toList(),
    );
  }
}
