import 'package:chack_chack/employer/home/RHomePage.dart';
import 'package:chack_chack/employer/signup/RSignUpPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RSignUpPage(),
    );
  }
}
