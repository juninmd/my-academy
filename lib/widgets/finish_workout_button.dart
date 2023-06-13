import 'package:flutter/material.dart';
import 'confirm_finish_workout.dart';

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
          await ConfirmFinishWorkout(
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
