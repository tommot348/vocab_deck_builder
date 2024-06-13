import 'dart:convert';
import 'config.dart';
import 'package:http/http.dart' as http;

import 'abstract_tranlator.dart';

class PonsTranslation extends AbstractTranslator {
  final _conf = Config();
  @override
  Future<Map<String, String>> getTranslation(String word, String lang) async {
    var resp = await http.get(
        Uri(
            scheme: "https",
            host: "api.pons.com",
            path: "/v1/dictionary",
            queryParameters: {"l": lang, "q": word}),
        headers: {"X-Secret": _conf.getTranslatorConfig("pons")["api-key"]!});
    if (resp.statusCode == 200) {
      List<dynamic> result = jsonDecode(resp.body);
      var (translation, description) = _getTranslationResult(result);
      return {"translation": translation, "description": description};
    }
    return {};
  }

  (String, String) _getTranslationResult(List<dynamic> json) {
    var translation = "";
    var description = "";
    var {"hits": hits} = json[0];
    var entrynum = 1;
    for (var entry in hits) {
      translation += "Entry $entrynum:<br>\n";
      description += "Entry $entrynum:<br>\n";
      entrynum++;
      switch (entry) {
        case {"type": "entry", "roms": List<dynamic> roms}:
          var romnum = 1;
          for (var {
                "wordclass": wordclass,
                "arabs": List<dynamic> arabs,
                "headword_full": romDescription,
              } in roms) {
            description += "$romnum\n$romDescription<br>\n";
            translation += "$romnum $wordclass\n<br>";
            for (var {"translations": List<dynamic> translations} in arabs) {
              for (var {"source": source, "target": target} in translations) {
                translation += "$source => $target<br>\n";
              }
            }
            ++romnum;
          }
          break;
        case {"type": "translation", "target": String target}:
          translation += "$target\n";
          break;
      }
    }
    return (translation, description);
  }

  @override
  Future<List<(String, String)>> getSupportedLanguages() async {
    var result = <(String, String)>[];
    var resp = await http.get(
      Uri(
          scheme: "https",
          host: "api.pons.com",
          path: "/v1/dictionaries",
          queryParameters: {"language": "en"}),
    );
    if (resp.statusCode == 200) {
      for (var element in jsonDecode(resp.body)) {
        result.add((element['key'], element['simple_label']));
      }
    }
    result.sort((a, b) {
      var (_, a1) = a;
      var (_, b1) = b;
      return a1.compareTo(b1);
    });
    return result;
  }

  @override
  List<String> getSupportedColumnTypes() {
    return ["translation", "description"];
  }

  @override
  Map<String, Map<String, String>> getDefaultColumnConfig() {
    return {
      "Input": {"data": "input", "type": "TextField"},
      "Translation": {"data": "translation", "type": "TextArea"},
      "Description": {"data": "description", "type": "TextArea"}
    };
  }
}
