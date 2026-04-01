import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 109, 40, 228))),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 109, 40, 228),
          title: const Text('Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
