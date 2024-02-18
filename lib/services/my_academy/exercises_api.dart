import '../../models/exercise.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Exercise>> getExercises() async {
  return await httpApi.request<Exercise>('get', 'exercises', Exercise.fromJson);
}

Future<Exercise> getExerciseById(int id) async {
  return await httpApi.request<Exercise>('get', 'exercises/$id', Exercise.fromJson);
}

Future<Exercise> postExercise(Exercise body) async {
  return await httpApi.request<Exercise>('post', 'exercises', Exercise.fromJson,
      body: body);
}

Future<Exercise> putExercise(Exercise body) async {
  return await httpApi.request<Exercise>(
      'put', 'exercises/${body.id}', Exercise.fromJson,
      body: body);
}

Future<void> deleteExercise(int id) async {
  await httpApi.request('delete', 'exercises/$id', null);
}
