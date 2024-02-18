import '../../models/workout.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Workout>> getWorkouts() async{
  return await httpApi.request<Workout>('get', 'workouts', Workout.fromJson);
}

Future<Workout> getWorkoutById(int id)async {
  return await httpApi.request<Workout>('get', 'workouts/$id', Workout.fromJson);
}

Future<Workout> postWorkout(Workout body)async {
  return await httpApi.request<Workout>('post', 'workouts', Workout.fromJson,
      body: body);
}

Future<Workout> putWorkout(Workout body) async{
  return await httpApi.request<Workout>(
      'put', 'workouts/${body.id}', Workout.fromJson,
      body: body);
}

Future<void> deleteWorkout(int id) async {
  await httpApi.request('delete', 'workouts/$id', null);
}
