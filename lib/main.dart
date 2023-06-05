import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_academy/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino do dia',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF512DA8), // Roxo profundo sugerido pelo Alfred
        scaffoldBackgroundColor: const Color(0xFF121212),
        splashColor: const Color(0xFFFF4081), // Cor de destaque sugerida pelo Alfred
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.transparent),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const HomePage(),
    );
  }
}
