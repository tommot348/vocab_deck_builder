import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import 'rows_provider.dart';

class VocabField extends StatefulWidget {
  final String value;

  final String data;

  final String type;

  final String title;

  final Key rowKey;

  final bool showHtml;

  const VocabField({
    super.key,
    required this.title,
    required this.value,
    required this.data,
    required this.type,
    required this.rowKey,
    required this.showHtml,
  });

  @override
  State<VocabField> createState() => _VocabFieldState();
}

class _VocabFieldState extends State<VocabField> {
  late TextEditingController controller;
  late String htmlContent;
  late String noHtmlContent;
  FocusNode focus = FocusNode();
  var lineNum = 4;
  @override
  void didUpdateWidget(covariant VocabField oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      noHtmlContent =
          parse("<p>${widget.value}</p>").documentElement?.text ?? "";
      htmlContent = widget.value;
    });
  }

  @override
  void initState() {
    super.initState();
    noHtmlContent = parse("<p>${widget.value}</p>").documentElement?.text ?? "";
    htmlContent = widget.value;
    var dataToShow = widget.showHtml || (widget.data == "input")
        ? htmlContent
        : noHtmlContent;
    controller =
        TextEditingController.fromValue(TextEditingValue(text: dataToShow));
    controller.addListener(() {
      if (widget.showHtml || (widget.data == "input")) {
        final String text = controller.text;
        htmlContent = text;
        noHtmlContent = parse("<p>$text</p>").documentElement?.text ?? "";
        var rp = RowsProvider.of(context);
        var index =
            rp.rows.indexWhere((element) => element.key == widget.rowKey);
        rp.rows[index].values[widget.title] = text;
      }
    });
    if (controller.text == "" && widget.data == "input") {
      focus.requestFocus();
    }
    focus.addListener(() async {
      if (focus.hasFocus) {
        setState(() {
          lineNum = 16;
        });
      } else {
        setState(() {
          lineNum = 4;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.showHtml ? htmlContent : noHtmlContent;
    Widget input = switch (widget.type) {
      "TextField" => TextField(
          controller: controller,
          focusNode: focus,
          readOnly: widget.data != "input" && !widget.showHtml,
          autofocus: widget.data == "input" && controller.text == "",
        ),
      _ => TextField(
          controller: controller,
          minLines: 4,
          maxLines: lineNum,
          keyboardType: TextInputType.multiline,
          focusNode: focus,
          readOnly: !widget.showHtml,
          autocorrect: false,
        ),
    };
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                border: Border.all(
                  width: 2,
                  color: Theme.of(context).primaryColor,
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: input,
          ),
        ],
      ),
    );
  }
}
