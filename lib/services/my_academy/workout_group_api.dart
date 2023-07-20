import "dart:convert";
import 'package:http/http.dart' as http;
import "../../models/workout_group.dart";
import "../my_academy_api.dart";

Future<List<WorkoutGroup>> getWorkoutGroups(int idUser) async {
  try {
    final url = Uri.parse("$host/workouts-groups/$idUser");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as List<dynamic>;
      final workoutGroups = jsonResponse.map((data) {
        return WorkoutGroup.fromJson(data);
      }).toList();
      return workoutGroups;
    } else {
      throw Exception("Failed to load workout groups");
    }
  } catch (exception) {
    throw Exception("Failed to load workout groups");
  }
}

Future<WorkoutGroup> getWorkoutGroupById(int id) async {
  final url = Uri.parse("${host}/workouts-groups/${id}");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutGroup.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutGroup> getWorkoutGroupExercisesById(int id) async {
  final url = Uri.parse("${host}/workouts-groups/${id}/exercises");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutGroup.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutGroup> postWorkoutGroup(WorkoutGroup body) async {
  final url = Uri.parse("${host}/workouts-groups");
  final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body.toJson()),
      encoding: utf8);

  if (response.statusCode == 201) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutGroup.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutGroup> putWorkoutGroup(WorkoutGroup body) async {
  final url = Uri.parse("${host}/workouts-groups/${body.id}");
  final response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutGroup.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteWorkoutGroup(int id) async {
  final url = Uri.parse("${host}/workouts-groups/${id}");
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
