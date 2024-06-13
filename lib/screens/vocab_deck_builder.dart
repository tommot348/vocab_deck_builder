import 'package:flutter_svg/flutter_svg.dart';
import '/config.dart';
import 'home_screen.dart';

import 'package:flutter/material.dart';

class VocabDeckBuilder extends StatefulWidget {
  const VocabDeckBuilder({super.key});

  @override
  State<VocabDeckBuilder> createState() => _VocabDeckBuilderState();
}

class _VocabDeckBuilderState extends State<VocabDeckBuilder> {
  Config conf = Config();

  var appTitle = 'Vocabulary Deck builder';
  var themeData = ThemeData(
    colorScheme:
        ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 122, 34))
            .copyWith(primary: const Color.fromARGB(255, 247, 145, 30)),
    useMaterial3: true,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: conf.isLoaded(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              title: appTitle,
              theme: themeData,
              home: const HomeScreen(),
            );
          } else {
            return MaterialApp(
                title: appTitle,
                theme: themeData,
                home: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "book.svg",
                          height: MediaQuery.of(context).size.height / 10,
                          width: MediaQuery.of(context).size.width / 10,
                        ),
                        const Text(
                          "loading",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ));
          }
        });
  }
}
