import 'package:flutter/material.dart';
import '/model/translation_row.dart';

class RowsProvider extends InheritedWidget {
  final bool showHtml;

  final int revision;

  const RowsProvider({
    super.key,
    required super.child,
    required this.rows,
    required this.columnConfig,
    required this.showHtml,
    required this.revision,
  });
  final List<TranslationRow> rows;
  final Map<String, Map<String, String>> columnConfig;
  static RowsProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RowsProvider>()!;
  }

  @override
  bool updateShouldNotify(RowsProvider oldWidget) {
    var showHtmlChanged = (oldWidget.showHtml != showHtml);
    return (oldWidget.rows.length != rows.length) ||
        showHtmlChanged ||
        (oldWidget.revision != revision);
  }
}
