import 'package:flutter/material.dart';
// import 'gameex.dart';

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

class CustomGrid extends StatelessWidget {

  const CustomGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row with one item spanning two columns
        // Container(
        //   color: Colors.blue,
        //   height: 100,
        //   width: double.infinity,
        //   alignment: Alignment.center,
        //   child: const Text(
        //     'Item 1',
        //     style: TextStyle(color: Colors.white, fontSize: 20),
        //   ),
        // ),
        // Grid with two columns
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children:List.generate(10, (index) {
            return Center(
              child: ItemWidget(
                text : 'Item $index'
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
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return 
    GestureDetector(
      onTap: () {
        print('Item $text clicked');
        // Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const Game1()),
        //     );
      },
      child: Card(
        child: SizedBox(
          child: Center(child: Text(text)),
        ),
      ),
    );
  }
}