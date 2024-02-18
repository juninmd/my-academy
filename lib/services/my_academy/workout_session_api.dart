import '../../dto/workout-summary.dart';
import '../../models/workout_session.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

getWorkoutSessions(idUser) async {
  return await httpApi.request<WorkoutSession>(
      'get', 'workouts-sessions/users/${idUser}', WorkoutSession.fromJson);
}

Future<WorkoutSession> getWorkoutSessionById(int id) async {
  return await httpApi.request<WorkoutSession>(
      'get', 'workouts-sessions/${id}', WorkoutSession.fromJson);
}

Future<WorkoutSession> postWorkoutSession(WorkoutSession body) async {
  return await httpApi.request<WorkoutSession>(
      'post', 'workouts-sessions', WorkoutSession.fromJson,
      body: body);
}

Future<WorkoutSession> putWorkoutSession(WorkoutSession body) async {
  return await httpApi.request<WorkoutSession>(
      'put', 'workouts-sessions/${body.id}', WorkoutSession.fromJson,
      body: body);
}

Future<void> deleteWorkoutSession(int id) async {
  return await httpApi.request<WorkoutSession>(
      'put', 'workouts-sessions/${id}', null);
}

Future<WorkoutSummary> getWorkoutSummary(int idUser) async {
  return await httpApi.request<WorkoutSummary>(
      'get', 'workouts-sessions/${idUser}/summary', WorkoutSummary.fromJson);
}
