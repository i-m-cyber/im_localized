import 'package:flutter/material.dart';
import 'package:im_localized/im_localized.dart';

abstract class LocaleKeys {
  static const languageFlag = 'languageFlag';
  static const hiMessage = 'hiMessage';
  static const increment = 'increment';
  static const itemCounter = 'itemCounter';
}

final _initialTranslations = [
  {
    "@@locale": "en",
    LocaleKeys.languageFlag: "🇺🇸",
    LocaleKeys.hiMessage: "Hi {name}!",
    LocaleKeys.increment: "Increment",
    LocaleKeys.itemCounter: '''Currently there {
        count,
        plural,
          =0{are no items}
          =1{is one item}
          other{are # items}
      } in this app''',
  },
  {
    "@@locale": "es",
    LocaleKeys.languageFlag: "🇪🇸",
    LocaleKeys.hiMessage: "¡Hola {name}!",
    LocaleKeys.increment: "Incremento",
    LocaleKeys.itemCounter: '''Actualmente hay {
        count,
        plural,
          =0{no hay elementos}
          =1{un elemento}
          other{# elementos}
      } en esta aplicación''',
  },
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImLocalizedApp.ensureInitialized();

  runApp(
    ImLocalizedApp.fromList(
      app: const MyApp(),
      initialTranslations: _initialTranslations,
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
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
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
