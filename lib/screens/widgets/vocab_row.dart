import 'package:flutter/material.dart';
import '/model/translation_row.dart';
import '/screens/widgets/rows_provider.dart';
import '/screens/widgets/vocab_checkbox.dart';
import 'vocab_field.dart';

class VocabRow extends StatelessWidget {
  final Null Function() onDelete;

  const VocabRow({
    super.key,
    required this.rowData,
    required this.onDelete,
  });
  final TranslationRow rowData;
  @override
  Widget build(BuildContext context) {
    final columnConfig = RowsProvider.of(context).columnConfig;
    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.9),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: VocabCheckbox(rowData: rowData),
          ),
          Flexible(
            flex: 10,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column in columnConfig.keys)
                  VocabField(
                    rowKey: rowData.key,
                    value: rowData.values[column]!,
                    data: columnConfig[column]!["data"]!,
                    type: columnConfig[column]!["type"]!,
                    showHtml: RowsProvider.of(context).showHtml,
                    title: column,
                  ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
            ),
          )
        ],
      ),
    );
  }
}
