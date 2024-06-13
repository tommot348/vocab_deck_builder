import 'package:vocab_deck_builder/screens/widgets/column_config.dart';

import '/config.dart';
import '/io_helper.dart';
import '/model/deck.dart';
import 'table_page.dart';
import '/tranlators.dart';
import 'package:flutter/material.dart';

class NewDeckDialog extends StatefulWidget {
  const NewDeckDialog({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _NewDeckDialogSate();
}

class _NewDeckDialogSate extends State {
  String filename = "";
  String name = "";
  Config conf = Config();
  String translator = "";
  String language = "";
  List<String> availlableColumns = [];
  Map<UniqueKey, Map<String, String>> columns = {};
  Map<String, Map<String, String>> defaultColumnConfig = {};
  List<(String, String)> languages = [];
  bool useDefaultConfig = true;
  @override
  void initState() {
    super.initState();
    translator = conf.translators.first;
    var columns = ["input"] +
        Translators.getTranslator(translator).getSupportedColumnTypes();
    Translators.getTranslator(translator)
        .getSupportedLanguages()
        .then((value) => setState(() {
              languages = value;
              availlableColumns = columns;
              language = languages.first.$1;
            }));
    defaultColumnConfig =
        Translators.getTranslator(translator).getDefaultColumnConfig();
  }

  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Text(
                "New Deck",
                style: TextStyle(fontSize: 24),
              ),
              TextFormField(
                autofocus: true,
                onChanged: (value) {
                  var fname = "${value.replaceAll(" ", "_")}.csv";
                  setState(() {
                    name = value;
                    filename = fname;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  if (conf.deckNames.contains(value)) {
                    return "Name is already used";
                  }
                  return null;
                },
                decoration: const InputDecoration(label: Text("Name")),
              ),
              const SizedBox(
                height: 30,
              ),
              DropdownMenu(
                dropdownMenuEntries: [
                  for (String name in conf.translators)
                    DropdownMenuEntry(value: name, label: name)
                ],
                initialSelection: conf.translators.first,
                label: const Text("Translator"),
                expandedInsets: const EdgeInsets.all(10),
                onSelected: (value) async {
                  var langs = await Translators.getTranslator(value!)
                      .getSupportedLanguages();
                  var columns = ["input"] +
                      Translators.getTranslator(value)
                          .getSupportedColumnTypes();
                  var defaults =
                      Translators.getTranslator(value).getDefaultColumnConfig();
                  setState(() {
                    translator = value;
                    languages = langs;
                    availlableColumns = columns;
                    defaultColumnConfig = defaults;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownMenu(
                dropdownMenuEntries: [
                  for (var (name, description) in languages)
                    DropdownMenuEntry(value: name, label: description)
                ],
                initialSelection: languages.firstOrNull?.$1 ?? "waiting",
                label: const Text("Language"),
                enableSearch: true,
                expandedInsets: const EdgeInsets.all(10),
                onSelected: (value) => setState(() {
                  language = value!;
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("use default column config? "),
                  Checkbox(
                    value: useDefaultConfig,
                    onChanged: (value) => setState(() {
                      useDefaultConfig = value ?? false;
                    }),
                  ),
                ],
              ),
              if (!useDefaultConfig)
                ColumnConfig(
                  columns: columns,
                  availlableColumns: availlableColumns,
                ),
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  var path = "decks/$filename";
                  IOHelper.saveFile(path, "").then((value) {
                    var columnConfig = useDefaultConfig
                        ? defaultColumnConfig
                        : {
                            for (var col in columns.values)
                              col["name"]!: {
                                "data": col["data"]!,
                                "type": col["type"]!
                              }
                          };

                    var deck = Deck(
                      name: name,
                      file: filename,
                      translator: translator,
                      language: language,
                      columnConfig: columnConfig,
                    );
                    conf.addDeck(deck);
                    Navigator.pop(
                      context,
                      deck,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TablePage(
                          deck: deck,
                        ),
                      ),
                    );
                  });
                },
                child: const Text("ok"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text("cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
