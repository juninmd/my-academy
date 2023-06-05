import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../repository/workouts_repository.dart';

class FinishWorkoutButton extends StatelessWidget {
  final String channelName;
  final String message;
  Function callback;

  FinishWorkoutButton({super.key, required this.callback, required this.channelName, required this.message});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await _showMyDialog(context, message, channelName, callback);
      },
      label: const Text("Finalizar treino"),
      icon: const Icon(Icons.save),
      backgroundColor: Colors.deepPurple,
    );
  }
}

Future<void> _showMyDialog(context, message, channel, callback) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmação'),
        content: Text('Deseja finalizar seu treino?'),
        actions: <Widget>[
          TextButton(
            child: Text('Sim'),
            onPressed: () async {
              postFinishWorkout(channel, message);
              // await saveExerciseOfDay();
              _showAlreadWorkout(context);
              callback();
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text('Não'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}

void postFinishWorkout(channel, message)   {
  const botToken = String.fromEnvironment('TELEGRAM_TOKEN');
  final chatId = channel;
  final url = Uri.https('api.telegram.org', '/bot$botToken/sendMessage', {
    'chat_id': chatId,
    'text': message,
  });
  http.post(url);
}

void _showAlreadWorkout(BuildContext context) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
    content: Text('Você treinou hoje, continue firme assim!'),
    duration: Duration(seconds: 5), // Optional: Set a custom duration
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}