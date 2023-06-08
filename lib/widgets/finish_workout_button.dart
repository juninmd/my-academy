import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';

class FinishWorkoutButton extends StatelessWidget {
  final String channelName;
  final String message;
  final int workoutGroupId;
  Function callback;

  FinishWorkoutButton(
      {super.key,
      required this.callback,
      required this.channelName,
      required this.workoutGroupId,
      required this.message});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
        onPressed: () async {
          await _showMyDialog(
              context, message, channelName, callback, workoutGroupId);
        },
        label: const Text(
          "Finalizar treino",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.red,
      );
}

Future<void> _showMyDialog(
        context, message, channel, callback, workoutGroupId) async =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Deseja finalizar seu treino?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Sim'),
            onPressed: () async {
              var body = WorkoutSession(
                  date: DateTime.now(), workoutGroupId: workoutGroupId);
              await postWorkoutSession(body);
              postFinishWorkout(channel, message);
              _showAlreadWorkout(context);
              callback();
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: const Text('Não'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );

void postFinishWorkout(channel, message) {
  const botToken = String.fromEnvironment('TELEGRAM_TOKEN');
  final chatId = channel;
  final url = Uri.https('api.telegram.org', '/bot$botToken/sendMessage', {
    'chat_id': chatId,
    'text': message,
  });
  http.post(url);
}

void _showAlreadWorkout(BuildContext context) {
  final snackBar = const SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
    content: Text('Você treinou hoje, continue firme assim!'),
    duration: Duration(seconds: 5), // Optional: Set a custom duration
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
