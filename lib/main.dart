import 'package:flutter/material.dart';
import 'package:my_academy/pages/exercise_group_page.dart';
import 'package:my_academy/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino do dia',
      // theme: ThemeData(
      //   brightness: Brightness.dark,
      //   primaryColor: Colors.deepPurple,
      //   scaffoldBackgroundColor: Colors.deepPurple,
      //   splashColor: Colors.deepPurple,
      //   textTheme: const TextTheme(
      //     bodyLarge: TextStyle(color: Colors.white38),
      //     bodyMedium: TextStyle(color: Colors.white60),
      //   ),
      //   bottomAppBarTheme: const BottomAppBarTheme(color: Colors.transparent),
      // ),
      home: HomePage(),
    );
  }
}
