import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

/// The `GameTest` class is a stateless widget that initializes the game with a given game number.
/// It builds the `ImageSection` widget with the provided game number.

class GameTest extends StatelessWidget {
  const GameTest({super.key, required this.gameNumber});

  final int gameNumber;

  @override
  Widget build(BuildContext context) {
    return ImageSection(gameNumber: gameNumber);
  }
}

/// The `ImageSection` class is a stateful widget that displays the game images and handles game logic.
/// It initializes the game with a given game number and loads the JSON data for the game.
class ImageSection extends StatefulWidget {
  const ImageSection({super.key, required this.gameNumber});

  final int gameNumber;

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

/// The `_ImageSectionState` class manages the state of the `ImageSection` widget.
/// It handles loading JSON data, managing the game timer, and updating the score.
class _ImageSectionState extends State<ImageSection> {
  List jsonList = [];
  int _score = 0;
  late int gameNumber;
  late GameTimer _gameTimer;
  int scoreGlobal = 0;

  @override
  void initState() {
    super.initState();
    gameNumber = widget.gameNumber;
    _loadJsonData();
    _gameTimer = GameTimer(onTick: _onTick);
    _gameTimer.start();
  }

  /// Loads JSON data from the assets and updates the state with the loaded data.
  Future<void> _loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/games.json');
    final jsonData = json.decode(jsonString);

    setState(() {
      jsonList = jsonData;
    });
  }

  /// Updates the elapsed time in the game timer.
  void _onTick(int elapsedSeconds) {
    setState(() {
      _gameTimer.elapsedSeconds = elapsedSeconds;
    });
  }

  /// Resets the game score and the game timer.
  void _resetScore() {
    setState(() {
      // scoreGlobal += _score;
      _score = 0;
      _gameTimer.reset();
    });
  }

  /// Increments the game score and shows a message when a character is found.
  /// If all characters are found, it stops the timer and shows the completion dialog.
  void _incrementScore(BuildContext context, String characterName) {
    setState(() {
      _score++;
    });

    _showMessage(context, '$characterName trouvé !');

    if (_score == jsonList[gameNumber]["perso"].length) {
      _gameTimer.stop();
      GameDialog.showCompletionDialog(
        context,
        _gameTimer.elapsedSeconds,
        gameNumber,
        jsonList.length,
        scoreGlobal: scoreGlobal,
        onRestart: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => GameTest(gameNumber: gameNumber)),
          );
          _resetScore();
          _loadJsonData();
        },
        onNextLevel: () {
          if (gameNumber + 1 < jsonList.length) {
            setState(() {
              gameNumber++;
              _resetScore();
              _gameTimer = GameTimer(onTick: _onTick);
              _gameTimer.start();
            });
          } else {
            _showMessage(context, 'Plus de niveaux disponibles !');
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Où est Charlie';
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
                    return Character(
                      image: element["image"],
                      found: element["found"],
                    );
                  }),
                ] else ...[
                  const Text('No characters found'),
                ],
              ],
            ),
          ),
          body: Stack(
            children: [
              InteractiveViewer(
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
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    '${_gameTimer.elapsedSeconds} s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  /// Shows a message using a SnackBar.
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Checks if the character is found based on the coordinates.
  bool _checkIfFound(final waldoCoords, final offset) {
    return ((waldoCoords["x"] + 20) > offset.dx &&
            offset.dx > (waldoCoords["x"] - 30)) &&
        ((waldoCoords["y"] + 20) > offset.dy &&
            offset.dy > (waldoCoords["y"] - 30));
  }
}

/// The `Character` class is a stateless widget that displays a character image.
/// It shows the character image in grey if the character is found.
class Character extends StatelessWidget {
  const Character({super.key, required this.image, required this.found});

  final String image;
  final bool found;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Image.asset(
        'images/$image',
        width: 30,
        height: 30,
        color: found ? Colors.grey : null,
      ),
    );
  }
}

/// The `GameTimer` class manages the game timer.
/// It starts, stops, and resets the timer, and calls the onTick callback every second.
class GameTimer {
  GameTimer({required this.onTick});

  final Function(int) onTick;
  late Timer _timer;
  int elapsedSeconds = 0;

  /// Starts the game timer and calls the onTick callback every second.
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      onTick(elapsedSeconds);
    });
  }

  /// Stops the game timer.
  void stop() {
    _timer.cancel();
  }

  /// Resets the game timer.
  void reset() {
    elapsedSeconds = 0;
  }
}

/// The `GameDialog` class provides a static method to show the completion dialog.
/// It shows the elapsed time and the final score, and provides options to restart or go to the next level.
class GameDialog {
  static void showCompletionDialog(
    BuildContext context,
    int elapsedSeconds,
    int gameNumber,
    int totalGames, {
    required VoidCallback onRestart,
    required VoidCallback onNextLevel,
    scoreGlobal
  }) {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    String time = '$minutes:$seconds';

    int adjustedScore;
    if (elapsedSeconds <= 30) {
      adjustedScore = 3000;
    } else if (elapsedSeconds <= 90) {
      adjustedScore = 2000;
    } else {
      adjustedScore = 1000;
    }


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bravo ! 🎉'),
          content: Text('Vous avez trouvé tous les personnages en $time ! \n'
              'Votre score final est : $adjustedScore pts\n'
              'Le score totale est : $scoreGlobal'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRestart();
              },
              child: const Text('Recommencer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onNextLevel();
              },
              child: const Text('Prochain niveau'),
            ),
          ],
        );
      },
    );
  }
}
