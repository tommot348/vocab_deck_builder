import 'package:vocab_deck_builder/abstract_tranlator.dart';

class NoTranslation extends AbstractTranslator {
  @override
  Map<String, Map<String, String>> getDefaultColumnConfig() {
    return {
      "input": {
        "data": "input",
        "type": "TextField",
      }
    };
  }

  @override
  List<String> getSupportedColumnTypes() {
    return [];
  }

  @override
  Future<List<(String, String)>> getSupportedLanguages() {
    return Future.value([("*", "*")]);
  }

  @override
  Future<Map<String, String>> getTranslation(String word, String lang) {
    return Future.value({"#!#": ""});
  }
}
