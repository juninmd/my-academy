import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/workout.dart';
import '../my_academy_api.dart';

Future<Workout> getWorkouts() async {
  var url = Uri.parse("${host}/workouts");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Workout.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Workout> getWorkoutById(int id) async {
  var url = Uri.parse("${host}/workouts/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Workout.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Workout> postWorkout(Workout body) async {
  var url = Uri.parse("${host}/workouts");
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Workout.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Workout> putWorkout(Workout body) async {
  var url = Uri.parse('${host}/workouts/${body.id}');
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Workout.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteWorkout(int id) async {
  var url = Uri.parse('${host}/workouts/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
