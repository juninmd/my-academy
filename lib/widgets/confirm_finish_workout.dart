import 'package:my_academy/widgets/snackbar.dart';

import '../constants.dart';
import '../models/workout_session.dart';
import '../services/my_academy/workout_session_api.dart';
import '../services/telegram_api.dart';
import 'confirm_dialog.dart';

Future<void> ConfirmFinishWorkout(context, workoutGroup, callback) async =>
    ConfirmDialog(context, 'Confimração', 'Deseja finalizar seu treino?',
        () async {
      final message = '${getDateNow()} - ${workoutGroup.description}';

      final body =
          WorkoutSession(date: DateTime.now(), workoutGroupId: workoutGroup.id);

      await postWorkoutSession(body);
      postChannelMessage(message);
      snackBar(context, 'Você treinou hoje, continue firme assim!');
      callback();
    }, () {
      callback();
    });
