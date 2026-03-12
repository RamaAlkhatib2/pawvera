import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawVera',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFBF6EE),
      ),
      home: const Home(),
    );
  }
}

