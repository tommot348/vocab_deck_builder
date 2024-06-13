import 'package:flutter/material.dart';

import '/config.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String ponsApiKey = Config().getTranslatorConfig("pons")["api-key"]!;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        child: Form(
      child: ListView(children: [
        const Text("Settings"),
        TextFormField(
          initialValue: ponsApiKey,
          onChanged: (value) => setState(() {
            ponsApiKey = value;
          }),
          decoration: const InputDecoration(
            label: Text("Pons Api Key"),
          ),
        ),
        TextButton(
          onPressed: () {
            Config().setTranslatorConfigValue(
                translator: "pons", name: "api-key", value: ponsApiKey);
            Navigator.pop(context);
          },
          child: const Text("save and close"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("cancel"),
        )
      ]),
    ));
  }
}
