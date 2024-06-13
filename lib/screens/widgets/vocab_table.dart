import 'package:flutter/material.dart';
import '/abstract_tranlator.dart';
import 'vocab_row.dart';

import 'rows_provider.dart';

class VocabTable extends StatefulWidget {
  final String filename;

  final String language;

  final AbstractTranslator translator;

  final Map<String, Map<String, String>> columnConfig;

  const VocabTable(
      {super.key,
      required this.filename,
      required this.language,
      required this.translator,
      required this.columnConfig});

  @override
  State<VocabTable> createState() => _VocabTableState();
}

class _VocabTableState extends State<VocabTable> {
  @override
  Widget build(BuildContext context) {
    var rows = RowsProvider.of(context).rows;
    return Column(
      children: [
        Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  var row = rows[index];
                  return VocabRow(
                      key: row.key,
                      rowData: row,
                      onDelete: () {
                        setState(() {
                          rows.removeWhere((element) => element.key == row.key);
                        });
                      });
                },
                separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 1,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                itemCount: rows.length))
      ],
    );
  }
}
