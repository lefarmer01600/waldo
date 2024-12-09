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
                
                  ...(jsonList[gameNumber]["perso"] as List)
                      .map<Widget>((element) {
                        print(element);
                    if (!element["found"]) {
                      return Image.asset(
                        'images/${element["image"]}',
                        width: 30,
                        height: 30,
                      );
                    } else {
                      return Image.asset(
                        'images/${element["image"]}',
                        width: 30,
                        height: 30,
                        color: Colors.grey,
                      );
                    }
                  }),

                  // Image.asset(
                  //   'images/waldo.jpg',
                  //   width: 30,
                  //   height: 30,
                  // ),
                  // const SizedBox(width: 0),
                  // Image.asset(
                  //   'images/odlaw.jpg',
                  //   width: 30,
                  //   height: 30,
                  // ),
                  // const SizedBox(width: 0),
                  // Image.asset(
                  //   'images/wizard.jpg',
                  //   width: 30,
                  //   height: 30,
                  // ),
                ],
              ),
            ),
            body: Expanded(
              child: InteractiveViewer(
                scaleEnabled: true,
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3,
                constrained: false,
                boundaryMargin: EdgeInsets.zero,
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    final offset = details.localPosition;

                    jsonList[gameNumber]["perso"].forEach((element) {
                      if (_checkIfFound(element["coords"], offset) &&
                          !element["found"]) {
                        _incrementScore(context, element["name"]);
                        element["found"] = true;
                      }
                    });

                    print(
                        "Clic détecté aux coordonnées : ${offset.dx}, ${offset.dy}");
                  },
                  child: Image.asset(
                    'images/${jsonList[gameNumber]["image"]}',
                    // width: 1000,
                    // height: 1000,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )));
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

// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   final TransformationController _viewTransformationController =
//       TransformationController();

//   @override
//   void initState() {
//     super.initState();
//     final zoomFactor = 0.61;
//     final xTranslate = 000.0;
//     final yTranslate = 000.0;

//     // Apply initial transformation matrix values
//     _viewTransformationController.value = Matrix4.identity()
//       ..setEntry(0, 0, zoomFactor)
//       ..setEntry(1, 1, zoomFactor)
//       ..setEntry(2, 2, zoomFactor)
//       ..setEntry(0, 3, -xTranslate)
//       ..setEntry(1, 3, -yTranslate);
//   }

//   @override
//   void dispose() {
//     _viewTransformationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: InteractiveViewer(
//             // transformationController: _viewTransformationController,
//             scaleEnabled: true,
//             panEnabled: true,
//             minScale: 0.5,
//             maxScale: 3,
//             constrained: false, // Allow unrestricted child size
//             boundaryMargin: EdgeInsets.zero,
//             child: Image.asset(
//               'images/level-1.jpg',
//               width: 1000,
//               height: 1000,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
