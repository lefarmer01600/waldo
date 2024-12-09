import 'dart:convert'; // Pour décoder le JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'game_test.dart';

/// The main function is the entry point of the application.
void main() {
  runApp(const MyApp());
}

/// MyApp is the root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CustomGrid());
  }
}

/// CustomGrid is a stateful widget that displays a grid of items loaded from a JSON file.
class CustomGrid extends StatefulWidget {
  const CustomGrid({super.key});

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

/// _CustomGridState is the state class for CustomGrid.
class _CustomGridState extends State<CustomGrid> {
  List jsonList = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  /// Loads JSON data from the assets and updates the state.
  Future<void> _loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/games.json');
    final jsonData = json.decode(jsonString);

    setState(() {
      jsonList = jsonData;
    });
  }

  void _showRulesModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Règles du jeu'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. Votre but est de trouver Charlie et ses camarades disperser dans différents monde.'),
                Text('2. Plus vous prennez du temps à le/les trouver moins vous aurez de point.'),
                Text('3. Saurez-vous retrouver Charlie et ammaser le plus de point ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Où est Charlie ?'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(jsonList.length, (index) {
                return Center(
                  child: ItemWidget(
                    text: jsonList[index]['name'],
                    image: jsonList[index]['image'],
                    index: index,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showRulesModal(context);
        },
        child: const Icon(Icons.help),
      ),
    );
  }
}

/// ItemWidget is a stateless widget that represents an item in the grid.
class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.text,
    required this.image,
    required this.index,
  });

  final String text;
  final String image;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GameTest(
                    gameNumber: index,
                  )),
        );
      },
      child: Card(
        child: SizedBox(
          child: Stack(
            children: [
              ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    'images/$image',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )),
              Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
