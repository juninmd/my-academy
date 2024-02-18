import '../../models/workout_personal_session.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<WorkoutPersonalSession>> getStudentsSessions(idUser) async {
  return await httpApi.request<WorkoutPersonalSession>('get', 'workouts-personals-sessions/students/${idUser}', WorkoutPersonalSession.fromJson);
}
