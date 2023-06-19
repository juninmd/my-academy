import 'package:flutter/material.dart';
import 'package:my_academy/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Treino do dia',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
        splashColor: Colors.black45,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.transparent),
      ),
      supportedLocales: const [Locale('pt', 'BR')],
      home: HomePage(),
    );
}
