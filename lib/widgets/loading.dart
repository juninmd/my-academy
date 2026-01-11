import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                darkTheme ? Colors.white : Colors.black,
              ),
              strokeWidth: 4,
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando',
              style: TextStyle(
                color: darkTheme ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> simulateWidgetLoading() async {
  // Simulate a delay for each widget loading
  await Future.delayed(const Duration(seconds: 0));
  return true; // Simulating that the widget is loaded
}
