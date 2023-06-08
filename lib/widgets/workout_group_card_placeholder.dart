import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WorkoutGroupCardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Future<bool> simulateWidgetLoading() async {
  // Simulate a delay for each widget loading
  await Future.delayed(const Duration(seconds: 0));
  return true; // Simulating that the widget is loaded
}

