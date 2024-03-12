import "../../models/workout_group.dart";
import "../my_academy_api.dart";

var httpApi = HttpApi();

Future<List<WorkoutGroup>> getWorkoutGroups(String idUser) async {
  return await httpApi.request<WorkoutGroup>(
      'get', 'workouts-groups/user/$idUser', WorkoutGroup.fromJson);
}

Future<WorkoutGroup> getWorkoutGroupById(int id) async {
  return await httpApi.request<WorkoutGroup>(
      'get', 'workouts-groups/${id}', WorkoutGroup.fromJson);
}

Future<WorkoutGroup> getWorkoutGroupExercisesById(int id) async {
  return await httpApi.request<WorkoutGroup>(
      'get', 'workouts-groups/${id}/exercises', WorkoutGroup.fromJson);
}

Future<void> postWorkoutGroup(WorkoutGroup body) async {
  await httpApi.request<WorkoutGroup>('post', 'workouts-groups', null,
      body: body);
}

Future<void> putWorkoutGroup(WorkoutGroup body) async {
  return await httpApi.request<WorkoutGroup>(
      'put', 'workouts-groups/${body.id}', null,
      body: body);
}

Future<void> deleteWorkoutGroup(int id) async {
  return await httpApi.request<WorkoutGroup>(
      'delete', 'workouts-groups/${id}', WorkoutGroup.fromJson);
}
