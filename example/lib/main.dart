import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';

import 'l10n/localization.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImLocalizedApp.ensureInitialized();

  runApp(
    ImLocalizedApp.fromList(
      app: const MyApp(),
      initialTranslations: initialTranslations,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    final title = LocaleKeys.hiMessage.translate(args: {'name': 'Sara'});

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
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
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: LocaleKeys.increment.translate(),
          child: const Icon(Icons.add),
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
