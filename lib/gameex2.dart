import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    const String appTitle = 'Where`s Waldo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text(appTitle), 
              const SizedBox(width: 10), 
              Image.asset(
                'images/waldo.jpg',
                width: 30,
                height: 30,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    ImageSection(
                      image: 'images/level-2.jpg',
                    ),
                  ],
                ),
              ),
            ),
              Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main.dart'); 
                  },
                  child: const Text('Revenir à l\'Accueil'),
                ),
                const SizedBox(height: 8), 
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/gameex3.dart');
                  },
                  child: const Text('Prochain niveau'),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class ImageSection extends StatelessWidget {
  const ImageSection({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        click(details.localPosition, context);
      },
      child: Image.asset(
        image,
        fit: BoxFit.cover,
      ),
    );
  }

  void click(Offset position, BuildContext context) {
    // Exemple de zones cliquables
    Rect waldoZone = Rect.fromLTWH(457, 320, 500, 50);
    Rect odlawZone = Rect.fromLTWH(211, 316, 500, 50); // x, y, largeur, hauteur
    Rect bonusZone = Rect.fromLTWH(543, 329, 500, 50);

    if (waldoZone.contains(position)) {
      _showMessage(context, 'Vous avez trouvé Waldo ! 🎉');
    }else if (odlawZone.contains(position)) {
      _showMessage(context, 'Vous avez trouvé Odlaw ! 🏴‍☠️🥷');
    } else if (bonusZone.contains(position)) {
      _showMessage(context, 'Bonus trouvé ! 🌟🪄');
    } else {
      _showMessage(context, 'Essayez encore...');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

