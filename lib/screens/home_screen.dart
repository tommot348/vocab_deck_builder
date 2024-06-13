import 'package:flutter_svg/flutter_svg.dart';
import 'really_dialog.dart';

import '/config.dart';
import '/model/deck.dart';
import 'new_deck_dialog.dart';
import 'settings_dialog.dart';
import 'table_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Deck> decks = Config().decks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            SvgPicture.asset(
              "book.svg",
              width: 50,
              height: 50,
            ),
            Text(
              "Vocabulary Lang Deck Builder",
              style: TextStyle(
                backgroundColor: Colors.white.withOpacity(0.8),
                shadows: [
                  BoxShadow(
                      offset: const Offset(1, 1),
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 2)
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const SettingsDialog(),
                );
              },
              icon: const Icon(Icons.settings))
        ],
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
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("bg2.jpg"),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
                Theme.of(context).cardColor, BlendMode.softLight),
            opacity: 0.4,
          ),
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Theme.of(context).cardColor.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Decks",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontFamily: "verdana",
                        shadows: [
                          BoxShadow(
                              offset: const Offset(3, 3),
                              blurRadius: 2,
                              blurStyle: BlurStyle.outer,
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.4))
                        ]),
                  ),
                  Expanded(
                      child: ListView.separated(
                    separatorBuilder: (context, index) => Container(
                      height: 1,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    itemBuilder: (context, index) {
                      var key = UniqueKey();
                      return Row(
                        key: key,
                        children: [
                          TextButton(
                            child: Text(
                              decks[index].name,
                              style: const TextStyle(fontSize: 24),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TablePage(
                                          deck: decks[index],
                                        )),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () async {
                              var really = await showDialog<bool>(
                                context: context,
                                builder: (context) => Dialog(
                                  child: ReallyDialog(
                                    decks: decks,
                                    index: index,
                                  ),
                                ),
                              );
                              if (!(really ?? false)) {
                                return;
                              }
                              Config().removeDeck(decks[index]);
                              setState(() {
                                decks.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete),
                          )
                        ],
                      );
                    },
                    itemCount: decks.length,
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("new deck"),
        onPressed: () async {
          var result = await showDialog<Deck?>(
            builder: (context) => const NewDeckDialog(),
            context: context,
          );
          setState(() {
            if (result != null) {
              decks.add(result);
            }
          });
        },
        icon: const Icon(Icons.add),
      ),
    );
  }
}
