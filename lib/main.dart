import 'package:flutter/material.dart';
import 'package:my_academy/exercise_group.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino do dia',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const ExerciseGroupPage(title: 'Treino do dia'),
    );
  }
}
