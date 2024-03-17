import 'package:flutter/widgets.dart';
import 'package:my_academy/widgets/snackbar.dart';

import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';
import 'confirm_dialog.dart';

Future<void> ConfirmFinishWorkout(context, workoutGroup, callback) async =>
    ConfirmDialog(context, 'Confirmação', 'Deseja finalizar seu treino?',
        () async {

      final body =
          WorkoutSession(date: DateTime.now(), workoutGroupId: workoutGroup.id);

      await postWorkoutSession(body);
      Navigator.of(context).pop(true);
      snackBar(context, 'Você treinou hoje, continue firme assim!');
      callback();
    }, () {
      callback();
    });
