import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/abstract_tranlator.dart';
import '/io_helper.dart';
import '/model/translation_row.dart';
import 'widgets/rows_provider.dart';
import 'widgets/vocab_table.dart';

import '/model/deck.dart';
import '/pons_translation.dart';

class TablePage extends StatefulWidget {
  final String title;

  final String filename;

  final String language;

  final Map<String, Map<String, String>> columnConfig;

  final AbstractTranslator translator;
  final Deck deck;

  TablePage({
    super.key,
    required this.deck,
  })  : title = deck.name,
        filename = deck.file,
        language = deck.language,
        columnConfig = deck.columnConfig,
        translator = switch (deck.translator) {
          "pons" => PonsTranslation(),
          _ => PonsTranslation()
        };

  @override
  State<TablePage> createState() => _TablePageState();
}

String getCSVData(List<TranslationRow> rows, List<String> headers) {
  var csv = const ListToCsvConverter(fieldDelimiter: ";");
  var list = rows.map((e) => e.values.values.toList()).toList();
  return csv.convert([headers] + list);
}

class _TablePageState extends State<TablePage> {
  bool isLoaded = false;
  bool showHtml = false;
  int revision = 0;
  List<TranslationRow> rows = [];
  late final AppLifecycleListener lifecycle;
  @override
  void initState() {
    super.initState();
    lifecycle = AppLifecycleListener(
      onStateChange: (value) async {
        await _saveFiles(
          filename: widget.filename,
          rows: rows,
          keys: widget.columnConfig.keys.toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    lifecycle.dispose();
    super.dispose();
  }

  Future _saveFiles({
    required String filename,
    required List<TranslationRow> rows,
    required List<String> keys,
  }) async {
    var csvdata = getCSVData(rows, keys);
    await IOHelper.saveFile("decks/$filename", csvdata);
    if (await IOHelper.isBasePathWritable()) {
      await IOHelper.saveFileExternal("decks/$filename", csvdata);
    } else {
      //TODO Error anzeigen
    }
  }

  @override
  Widget build(BuildContext context) {
    return RowsProvider(
      columnConfig: widget.columnConfig,
      rows: rows,
      showHtml: showHtml,
      revision: revision,
      child: FutureBuilder<List<TranslationRow>>(
        future: _getTranslationRows(widget.filename),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "loading",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          } else {
            if (!isLoaded) {
              rows.addAll(snapshot.data!);
            }
            isLoaded = true;

            return PopScope(
              canPop: true,
              onPopInvoked: (didPop) async {
                await _saveFiles(
                  rows: RowsProvider.of(context).rows,
                  filename: widget.filename,
                  keys: widget.columnConfig.keys.toList(),
                );
              },
              child: Scaffold(
                appBar: AppBar(
                  actions: [
                    Row(
                      children: [
                        const Text("show HTML"),
                        Checkbox(
                          value: showHtml,
                          onChanged: (value) {
                            setState(() {
                              showHtml = value ?? false;
                            });
                          },
                        )
                      ],
                    )
                  ],
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("bar.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: Text("Deck: ${widget.title}"),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                body: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: const AssetImage("bg2.jpg"),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).cardColor, BlendMode.softLight),
                    opacity: 0.4,
                  )),
                  child: VocabTable(
                    filename: widget.filename,
                    language: widget.language,
                    translator: widget.translator,
                    columnConfig: widget.columnConfig,
                  ),
                ),
                persistentFooterButtons: [
                  /*IconButton(
                      onPressed: () async {
                        await _saveFiles(
                          rows: RowsProvider.of(context).rows,
                          filename: widget.filename,
                          keys: widget.columnConfig.keys.toList(),
                        );
                      },
                      icon: const Icon(Icons.save)),*/
                  TextButton(
                      onPressed: () async {
                        var marked = rows.where((element) => element.marked);
                        for (var element in marked) {
                          final input = element.values[widget.columnConfig.keys
                              .firstWhere((element) =>
                                  widget.columnConfig[element]!["data"] ==
                                  "input")];
                          var translation = await widget.translator
                              .getTranslation(input!, widget.language);
                          var index =
                              rows.indexWhere((e) => e.key == element.key);
                          for (var column in translation.keys) {
                            var col = widget.columnConfig.entries.firstWhere(
                              (el) {
                                if (el.value["data"]! == column) {
                                  return true;
                                }
                                return false;
                              },
                              orElse: () => const MapEntry("", {}),
                            );
                            if (col.key == "") {
                              continue;
                            }
                            rows[index].values[col.key] = translation[column]!;
                          }
                          rows[index].marked = false;
                        }
                        setState(() {
                          revision += 1;
                        });
                      },
                      child: const Text("translate marked entries")),
                ],
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    var newRow = TranslationRow(
                      UniqueKey(),
                      values: {
                        for (var key in widget.columnConfig.keys) key: ""
                      },
                    );
                    setState(() {
                      rows.insert(0, newRow);
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

Future<List<TranslationRow>> _getTranslationRows(filename) async {
  var rows = <TranslationRow>[];
  var content = await IOHelper.loadFile("decks/$filename");
  var csv = const CsvToListConverter(
    fieldDelimiter: ";",
  );
  var list = csv.convert<String>(content, shouldParseNumbers: false);
  if (list.isEmpty) {
    return rows;
  }
  var headers = list[0];
  for (var row in list.getRange(1, list.length)) {
    var key = ValueKey(row[0]);
    var trow = TranslationRow(
      key,
      values: {for (int i = 0; i < headers.length; ++i) headers[i]: row[i]},
    );
    rows.add(trow);
  }
  return rows;
}
