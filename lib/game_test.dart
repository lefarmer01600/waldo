import 'dart:convert'; // Pour décoder le JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async'; //Pour le timer

// void main() => runApp(const GameTest(gameNumber: 0,));

class GameTest extends StatelessWidget {
  const GameTest({super.key, required this.gameNumber});

  final int gameNumber;

  @override
  Widget build(BuildContext context) {
    return ImageSection(gameNumber: gameNumber);
  }
}

class ImageSection extends StatefulWidget {
  const ImageSection({super.key, required this.gameNumber});

  final int gameNumber;

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  List jsonList = [];
  int _score = 0;
  // int gameNumber = 0;
  late int gameNumber;
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    gameNumber = widget.gameNumber;
    _loadJsonData();
    _startTimer();
  }

  Future<void> _loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/games.json');
    final jsonData = json.decode(jsonString);

    setState(() {
      jsonList = jsonData;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _resetScore() {
    setState(() {
      _score = 0;
      _elapsedSeconds = 0;
    });
  }

  void _incrementScore(BuildContext context, String characterName) {
    setState(() {
      _score++;
    });

    _showMessage(context, '$characterName trouvé !');

    // Tous trouvé
    if (_score == jsonList[gameNumber]["perso"].length) {
      _timer.cancel();
      final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
      String time = '$minutes:$seconds';

      showDialog(
        context: context,
        builder: (context) {
          int adjustedScore;
          if (_elapsedSeconds <= 30) {
            adjustedScore = 3000;
          } else if (_elapsedSeconds <= 90) {
            adjustedScore = 2000;
          } else {
            adjustedScore = 1000;
          }
          return AlertDialog(
            title: const Text('Bravo ! 🎉'),
            content: Text('Vous avez trouvé tous les personnages en $time ! \n'
                'Votre score final est : $adjustedScore pts'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => GameTest(gameNumber: gameNumber)),
                  );
                  _resetScore();
                  _loadJsonData();
                },
                child: const Text('Recommencer'),
              ),
              TextButton(
                onPressed: () {
                  if (gameNumber + 1 < jsonList.length) {
                    // Ensure we don't exceed available levels
                    setState(() {
                      gameNumber++; // Move to the next level
                      _score = 0; // Reset score for the new level
                      _elapsedSeconds = 0; // Reset timer for the new level
                    });
                  } else {
                    // Handle if no more levels are available (optional)
                    _showMessage(context, 'Plus de niveaux disponibles !');
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Prochain niveau'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Ou est Charlie';
    return MaterialApp(
        title: appTitle,
        home: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Text(appTitle),
                  const SizedBox(width: 5),
                  if (jsonList.isNotEmpty && gameNumber < jsonList.length) ...[
                    ...(jsonList[gameNumber]["perso"] as List)
                        .map<Widget>((element) {
                      if (!element["found"]) {
                        return Flexible(
                          child: Image.asset(
                            'images/${element["image"]}',
                            width: 30,
                            height: 30,
                          ),
                        );
                      } else {
                        return Flexible(
                          child: Image.asset(
                            'images/${element["image"]}',
                            width: 30,
                            height: 30,
                            color: Colors.grey,
                          ),
                        );
                      }
                    }),
                  ] else ...[
                    const Text('No characters found'),
                  ],
                ],
              ),
            ),
            body: InteractiveViewer(
                scaleEnabled: true,
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3,
                constrained: false,
                boundaryMargin: EdgeInsets.zero,
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    final offset = details.localPosition;
                    if (jsonList.isNotEmpty && gameNumber < jsonList.length) {
                      jsonList[gameNumber]["perso"].forEach((element) {
                        if (_checkIfFound(element["coords"], offset) &&
                            !element["found"]) {
                          _incrementScore(context, element["name"]);
                          element["found"] = true;
                        }
                      });
                    }

                    print(
                        "Clic détecté aux coordonnées : ${offset.dx}, ${offset.dy}");
                  },
                  child: jsonList.isNotEmpty && gameNumber < jsonList.length
                      ? Image.asset(
                          'images/${jsonList[gameNumber]["image"]}',
                          fit: BoxFit.cover,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _checkIfFound(final waldoCoords, final offset) {
    return ((waldoCoords["x"] + 20) > offset.dx &&
            offset.dx > (waldoCoords["x"] - 30)) &&
        ((waldoCoords["y"] + 20) > offset.dy &&
            offset.dy > (waldoCoords["y"] - 30));
  }
}