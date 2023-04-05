import 'package:flutter/material.dart';

class CaloriesProgressBar extends StatelessWidget {
  final int consumed;
  final int goal;
  final String description;
  final String unit;

  CaloriesProgressBar(
      {required this.consumed, required this.goal, required this.description, required this.unit});

  @override
  Widget build(BuildContext context) {
    double progress = consumed / goal;

    return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                description,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 8.0),
              Text(
                'Consumido: $consumed $unit / Objetivo: $goal $unit',
                style: TextStyle(fontSize: 12.0),
              ),
            ]));
  }
}
