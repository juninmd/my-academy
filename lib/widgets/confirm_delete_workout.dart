import 'package:flutter/widgets.dart';
import 'package:my_academy/widgets/snackbar.dart';

import '../services/my_academy/workout_group_api.dart';
import 'confirm_dialog.dart';

Future<void> ConfirmDeleteWorkout(context, workoutGroupId, callback) async =>
    ConfirmDialog(context, 'Confirmação', 'Deseja apagar seu treino?',
        () async {
      await disableWorkoutGroup(workoutGroupId);
      Navigator.of(context).pop(true);
      snackBar(context, 'Treino Apagado com sucesso');
      callback();
    }, () async {
      callback();
    });
