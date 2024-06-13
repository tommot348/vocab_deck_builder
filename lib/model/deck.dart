class Deck {
  String name;
  String file;
  String language;
  String translator;
  Map<String, Map<String, String>> columnConfig;
  Deck({
    required this.name,
    required this.file,
    required this.language,
    required this.translator,
    required this.columnConfig,
  });
}
