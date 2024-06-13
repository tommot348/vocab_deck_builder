import 'package:flutter/material.dart';

class ColumnConfig extends StatefulWidget {
  final Map<Key, Map<String, String>> columns;
  final List<String> availlableColumns;

  const ColumnConfig(
      {super.key, required this.columns, required this.availlableColumns});

  @override
  State<ColumnConfig> createState() => _ColumnConfigState();
}

class _ColumnConfigState extends State<ColumnConfig> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
            child: Text(
          "Column Configuration",
          style: TextStyle(fontSize: 24),
        )),
        for (var columnKey in widget.columns.keys)
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                        label: const Text("Name"),
                        constraints: BoxConstraints.loose(Size.infinite)),
                    onChanged: (value) =>
                        widget.columns[columnKey]!["name"] = value,
                  ),
                  trailing: IconButton(
                    onPressed: () => setState(() {
                      widget.columns
                          .removeWhere((key, value) => key == columnKey);
                    }),
                    icon: const Icon(Icons.delete),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownMenu(
                        label: const Text("Column Type"),
                        dropdownMenuEntries: [
                          for (var type in widget.availlableColumns)
                            DropdownMenuEntry(value: type, label: type)
                        ],
                        onSelected: (value) {
                          setState(() {
                            widget.columns[columnKey]!["data"] = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownMenu(
                        label: const Text("Input Type"),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                              value: "TextField", label: "TextField"),
                          DropdownMenuEntry(
                              value: "TextArea", label: "TextArea"),
                        ],
                        onSelected: (value) {
                          setState(() {
                            widget.columns[columnKey]!["type"] = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        IconButton(
            onPressed: () {
              setState(() {
                widget.columns[UniqueKey()] = {
                  "name": "",
                  "data": "",
                  "type": ""
                };
              });
            },
            icon: const Icon(Icons.add)),
      ],
    );
  }
}
