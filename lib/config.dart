import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'io_helper.dart';
import 'model/deck.dart';

class Config {
  dynamic _values;
  bool _loaded = false;
  // var configfile = File("config.json");
  static final Config _instance = Config._getInstance();
  void _initValues() async {
    var example = await rootBundle.loadString("config_example.json");
    if (!await IOHelper.fileExists("config.json")) {
      await IOHelper.saveFile("config.json", example);
    }
    var data = await IOHelper.loadFile("config.json");
    if (data.trim().isEmpty) {
      await IOHelper.saveFile("config.json", example);
      data = example;
    }
    _values = jsonDecode(data);
    if (await IOHelper.isBasePathWritable()) {
      await IOHelper.saveFileExternal("test.txt", "bla", "text/plain");
      await IOHelper.deleteFileExternal("test.txt");
    } else {
      //TODO: show error
    }
    _loaded = true;
  }

  Future<bool> isLoaded() async {
    while (!_loaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return true;
  }

  final JsonEncoder _enc = const JsonEncoder.withIndent('  ');

  factory Config() {
    return _instance;
  }

  Config._getInstance() {
    _initValues();
  }

  void addDeck(Deck deck) {
    _values["decks"].add({
      "name": deck.name,
      "file": deck.file,
      "translator": deck.translator,
      "language": deck.language,
      "columnConfig": deck.columnConfig
    });
    IOHelper.saveFile("config.json", _enc.convert(_values));
  }

  void removeDeck(Deck deck) {
    _values["decks"].removeWhere((value) => value["name"] == deck.name);
    IOHelper.saveFile("config.json", _enc.convert(_values));
    var path = "decks/${deck.file}";
    IOHelper.deleteFile(path);
  }

  List<Deck> get decks => _values["decks"].map<Deck>((x) {
        var columnConfig = {
          for (var key in x["columnConfig"].keys)
            key.toString(): {
              for (var innerKey in x["columnConfig"][key]!.keys)
                innerKey.toString(): x["columnConfig"][key][innerKey].toString()
            }
        };
        return Deck(
          name: x["name"],
          file: x["file"],
          language: x["language"],
          translator: x["translator"],
          columnConfig: columnConfig,
        );
      }).toList();
  List<String> get deckNames =>
      _values["decks"].map<String>((x) => x["name"].toString()).toList();
  List<String> get translators => (_values["translators"]).keys.toList();
  Map<String, String> getTranslatorConfig(String translatorName) {
    return {
      for (var MapEntry(:key, :value)
          in _values["translators"][translatorName].entries)
        key as String: value as String
    };
  }

  void setTranslatorConfigValue(
      {required String translator,
      required String name,
      required String value}) {
    _values["translators"][translator][name] = value;
    IOHelper.saveFile("config.json", _enc.convert(_values));
  }

  set basePath(x) {
    _values["basePath"] = x;
    IOHelper.saveFile("config.json", _enc.convert(_values));
  }

  get basePath => _values["basePath"] ?? "";
}
