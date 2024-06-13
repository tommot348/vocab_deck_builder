import 'package:flutter/foundation.dart';

class TranslationRow {
  bool marked;
  Key key;
  Map<String, String> values;
  TranslationRow(this.key, {required this.values}) : marked = false;
}
