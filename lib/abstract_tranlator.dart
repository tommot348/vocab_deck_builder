abstract class AbstractTranslator {
  Future<Map<String, String>> getTranslation(String word, String lang);
  Future<List<(String, String)>> getSupportedLanguages();
  List<String> getSupportedColumnTypes();
  Map<String, Map<String, String>> getDefaultColumnConfig();
}
