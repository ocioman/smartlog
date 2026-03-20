import 'package:flutter/material.dart';
import 'package:progettotps/login.dart';
import 'package:progettotps/signup.dart';

import 'home.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget{
  const App({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'BebasNeue',
      ),
      home: LoginPage(),
    );
  }
}