import 'package:flutter/material.dart';
import 'package:pawvera/pages/sign_in_page.dart';
import 'package:pawvera/pages/supplies_store.dart'; 
import 'package:pawvera/pages/store_details.dart';
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
      home: const SignInPage(),
    );
  }
}
