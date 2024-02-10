import '../../models/exercise.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Exercise>> getExercises() async {
  final url = 'exercises';
  var exercises =
      await httpApi.request<Exercise>('get', url, Exercise.fromJson);
  return exercises;
}

Future<Exercise> getExerciseById(int id) {
  final url = 'exercises/$id';
  return httpApi.request<Exercise>('get', url, Exercise.fromJson);
}

Future<Exercise> postExercise(Exercise body) {
  final url = 'exercises';
  return httpApi.request<Exercise>('post', url, Exercise.fromJson, body: body);
}

Future<Exercise> putExercise(Exercise body) {
  final url = 'exercises/${body.id}';
  return httpApi.request<Exercise>('put', url, Exercise.fromJson, body: body);
}

Future<void> deleteExercise(int id) async {
  final url = 'exercises/$id';
  await httpApi.request('delete', url, null);
}
