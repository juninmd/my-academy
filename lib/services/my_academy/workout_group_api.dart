import "../../models/workout_group.dart";
import "../my_academy_api.dart";

var httpApi = HttpApi();

Future<List<WorkoutGroup>> getWorkoutGroups(int idUser) async {
  return await httpApi.request<WorkoutGroup>('get',
      'workouts-groups/user/$idUser?activated=true', WorkoutGroup.fromJson);
}

Future<WorkoutGroup> getWorkoutGroupById(int id) async {
  return await httpApi.request<WorkoutGroup>(
      'get', 'workouts-groups/${id}', WorkoutGroup.fromJson);
}

Future<WorkoutGroup> getWorkoutGroupExercisesById(int id) async {
  return await httpApi.request<WorkoutGroup>(
      'get', 'workouts-groups/${id}/exercises', WorkoutGroup.fromJson);
}

Future<WorkoutGroup> postWorkoutGroup(WorkoutGroup body) async {
  return await httpApi.request<WorkoutGroup>(
      'post', 'workouts-groups', WorkoutGroup.fromJson);
}

Future<WorkoutGroup> putWorkoutGroup(WorkoutGroup body) async {
  return await httpApi.request<WorkoutGroup>(
      'put', 'workouts-groups/${body.id}', WorkoutGroup.fromJson);
}

Future<void> disableWorkoutGroup(int id) async {
  return await httpApi.request<WorkoutGroup>(
      'delete', 'workouts-groups/disable/${id}', WorkoutGroup.fromJson);
}
