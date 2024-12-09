import 'dart:convert'; // Pour décoder le JSON
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'game_test.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Grid Example'),
        ),
        body: const CustomGrid(),
      ),
    );
  }
}

class CustomGrid extends StatefulWidget {
  const CustomGrid({super.key});

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  List jsonList = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/games.json');
    final jsonData = json.decode(jsonString);

    setState(() {
      jsonList = jsonData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

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
        print('Item $text clicked');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameTest(gameNumber: index,)),
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
