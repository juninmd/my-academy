import 'package:flutter/material.dart';

class WorkoutGroupCardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final darkTheme = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: darkTheme ? Colors.grey[800]?.withOpacity(0.1) : Colors.grey[200]?.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 12,
              width: double.infinity,
              color: darkTheme ? Colors.grey[700] : Colors.grey[300],
            ),
            SizedBox(height: 8),
            Container(
              height: 12,
              width: double.infinity,
              color: darkTheme ? Colors.grey[700] : Colors.grey[300],
            ),
            SizedBox(height: 16),
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
