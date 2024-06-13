import 'no_translation.dart';

import 'abstract_tranlator.dart';
import 'pons_translation.dart';

class Translators {
  static AbstractTranslator getTranslator(String name) {
    return switch (name) {
      "pons" => PonsTranslation(),
      "no translation" => NoTranslation(),
      _ => PonsTranslation()
    };
  }
}
