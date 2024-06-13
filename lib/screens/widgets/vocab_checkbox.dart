import 'package:flutter/material.dart';
import '/model/translation_row.dart';
import 'rows_provider.dart';

class VocabCheckbox extends StatefulWidget {
  const VocabCheckbox({
    super.key,
    required this.rowData,
  });

  final TranslationRow rowData;

  @override
  State<VocabCheckbox> createState() => _VocabCheckboxState();
}

class _VocabCheckboxState extends State<VocabCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      onChanged: (value) {
        setState(() {
          var rp = RowsProvider.of(context);
          var index = rp.rows
              .indexWhere((element) => element.key == widget.rowData.key);
          rp.rows[index].marked = value ?? false;
        });
      },
      value: widget.rowData.marked,
    );
  }
}
