import 'package:flutter/material.dart';
import 'package:vocab_deck_builder/model/deck.dart';

class ReallyDialog extends StatelessWidget {
  const ReallyDialog({
    super.key,
    required this.decks,
    required this.index,
  });

  final List<Deck> decks;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Do you really want to delete the deck ${decks[index].name} ?",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("YES")),
          const SizedBox(
            height: 50,
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
        ],
      ),
    );
  }
}
