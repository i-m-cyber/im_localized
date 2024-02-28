import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:im_localized/src/generators/generate_localization_file.dart';
import 'package:intl/locale.dart';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> rawArgs) {
  final args = parseArgs(rawArgs);

  if (args.contains(CliArg.help)) {
    _printHelperDisplay();
    return;
  }

  if ({CliArg.download, CliArg.synchronize, CliArg.upload}
          .intersection(args)
          .length >
      1) {
    throw 'Only one argument of --download, --sync, --upload can be specified';
  }

  handleLangFiles();
}

void handleLangFiles() async {
  final current = Directory.current;
  const subPath = 'lib/l10n';
  final l10nPath = Directory(path.join(current.path, subPath));

  if (!await l10nPath.exists()) {
    printError('Source path does not exist: ${l10nPath.path}');
    return;
  }

  var files = await dirContents(l10nPath);

  final localTranslations = <Locale, Map<String, String>>{};

  for (var file in files) {
    final fileExt = path.extension(file.path).toLowerCase();

    if (!{'.json', '.jsonc', '.arb'}.contains(fileExt)) {
      continue;
    }

    final fileName = path.basenameWithoutExtension(file.path);

    try {
      final locale = Locale.parse(fileName);
      var json = await readJsonFile(file.path);
      try {
        if (json is! Map) {
          throw Exception(
              'Parsing locale file: JSON content must me a Map<String, String>');
        }

        json = json.cast<String, String>();

        if (json['@@locale'] != null &&
            json['@@locale'].toLowerCase() != fileName.toLowerCase()) {
          throw Exception(
              'filename and @@locale property must match, if both specified');
        }

        localTranslations[locale] = json as Map<String, String>;
      } catch (e) {
        printError('$fileName: ${e.toString()}');
        return;
      }
    } catch (e) {
      printError('Parsing locale file: Invalid locale identifier: $fileName');
      return;
    }
  }

  if (localTranslations.isEmpty) {
    printError('No locale files found. Please create *.json or *.arb files '
        'at ${l10nPath.path}\n'
        'i.e. ${path.join(l10nPath.path, 'en.json')}');
    return;
  }

  generateLocalesFile(localTranslations, l10nPath);
}

Future generateLocalesFile(
  Map<Locale, Map<String, String>> localTranslations,
  Directory l10nPath,
) async {
  final content = generateLocalizationFileFromMap(localTranslations);

  final file = File(path.join(l10nPath.path, 'localization.dart'));
  await file.writeAsString(content);

  printInfo('successfully saved to ${file.path}');
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}

Future<dynamic> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  // remove comments
  input = input.replaceAll(RegExp(r'\/\/.*\n'), '');
  // remove trailing commas
  input = input.replaceAll(RegExp(r',\s*}'), '}');
  return jsonDecode(input);
}

void printInfo(String info) {
  // ignore: avoid_print
  print('\u001b[32mim_localized: $info\u001b[0m');
}

void printError(String error) {
  // ignore: avoid_print
  print('\u001b[31m[ERROR] im_localized: $error\u001b[0m');
}

void _printHelperDisplay() {
  var parser = _generateArgParser(null);
  log(parser.usage);
}

ArgParser _generateArgParser(GenerateOptions? generateOptions) {
  var parser = ArgParser();

  parser.addOption(
    'download',
    abbr: 'd',
    help: 'download, merge with json and generate .dart file',
  );

  parser.addOption(
    'sync',
    abbr: 's',
    help: 'download, merge with json, generate .dart file and upload to server',
  );

  parser.addOption(
    'upload',
    abbr: 'u',
    help: 'generate .dart file and upload to server',
  );

  return parser;
}

class GenerateOptions {
  String? sourceDir;
  String? sourceFile;
  String? templateLocale;
  String? outputDir;
  String? outputFile;
  String? format;
  bool? skipUnnecessaryKeys;

  @override
  String toString() {
    return 'format: $format sourceDir: $sourceDir sourceFile: $sourceFile outputDir: $outputDir outputFile: $outputFile skipUnnecessaryKeys: $skipUnnecessaryKeys';
  }
}

Set<CliArg> parseArgs(List<String> args) {
  final parsedArgs = <CliArg>{};
  for (final arg in args) {
    final enumValue = CliArg.mapFromString[arg];
    if (enumValue == null) {
      throw 'Unknown argument: $arg';
    }
    parsedArgs.add(enumValue);
  }
  return parsedArgs;
}

enum CliArg {
  help({'--help', '-h'}), // help
  download({
    '--download',
    '-d'
  }), // download, merge with json and generate .dart file
  synchronize({
    '--sync',
    '-s'
  }), // download, merge with json, generate .dart file and upload to server
  upload({'--upload', '-u'}); // generate .dart file and upload to server

  final Set<String> argNames;

  const CliArg(this.argNames);

  static final mapFromString = {
    for (var enumValue in values)
      for (var argName in enumValue.argNames) argName: enumValue
  };
}
