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
          title: const Text(appTitle),
        ),
        // #docregion add-widget
        body: const SingleChildScrollView(
          child: Column(
            children: [
              ImageSection(
                image: 'images/level-1.jpg',
              ),
            ],
          ),
        ),
        // #enddocregion add-widget
      ),
    );
  }
}



// #docregion image-asset
class ImageSection extends StatelessWidget {
  const ImageSection({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    // #docregion image-asset
    return Image.asset(
      image,
      fit: BoxFit.cover,
    );
    // #enddocregion image-asset
  }
}
// #enddocregion image-section

// #docregion favorite-widget
class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({super.key});

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState();
}
// #enddocregion favorite-widget

// #docregion favorite-state, favorite-state-fields, favorite-state-build
class _FavoriteWidgetState extends State<FavoriteWidget> {
  // #enddocregion favorite-state-build
  bool _isFavorited = true;
  int _favoriteCount = 41;
  // #enddocregion favorite-state-fields

  // #docregion toggle-favorite
  void _toggleFavorite() {
    setState(() {
      if (_isFavorited) {
        _favoriteCount -= 1;
        _isFavorited = false;
      } else {
        _favoriteCount += 1;
        _isFavorited = true;
      }
    });
  }
  // #enddocregion toggle-favorite

  // #docregion favorite-state-build
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            icon: (_isFavorited
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border)),
            color: Colors.red[500],
            onPressed: _toggleFavorite,
          ),
        ),
        SizedBox(
          width: 18,
          child: SizedBox(
            child: Text('$_favoriteCount'),
          ),
        ),
      ],
    );
  }
  // #docregion favorite-state-fields
}
// #enddocregion favorite-state, favorite-state-fields, favorite-state-build
