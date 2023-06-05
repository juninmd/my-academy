import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/exercise.dart';
import '../my_academy_api.dart';

Future<Exercise> getExercises() async {
  var url = Uri.parse("${host}/exercises");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Exercise.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Exercise> getExerciseById(int id) async {
  var url = Uri.parse("${host}/exercises/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Exercise.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Exercise> postExercise(Exercise exercise) async {
  var url = Uri.parse("${host}/exercises");
  var response = await http.post(url, body: exercise);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Exercise.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Exercise> putExercise(Exercise exercise) async {
  var url = Uri.parse('${host}/exercises/${exercise.id}');
  var response = await http.post(url, body: exercise);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Exercise.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteExercise(int id) async {
  var url = Uri.parse('${host}/exercises/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
