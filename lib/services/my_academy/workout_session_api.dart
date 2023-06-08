import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../dto/workout-summary.dart';
import '../../models/workout_session.dart';
import '../my_academy_api.dart';

Future<WorkoutSession> getWorkoutSessions() async {
  final url = Uri.parse("${host}/workouts-sessions");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutSession.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutSession> getWorkoutSessionById(int id) async {
  final url = Uri.parse("${host}/workouts-sessions/${id}");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutSession.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutSession> postWorkoutSession(WorkoutSession body) async {
  final url = Uri.parse("${host}/workouts-sessions");
  final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body.toJson()),
      encoding: Encoding.getByName("utf-8"));

  if (response.statusCode == 201) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutSession.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutSession> putWorkoutSession(WorkoutSession body) async {
  final url = Uri.parse('${host}/workouts-sessions/${body.id}');
  final response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutSession.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteWorkoutSession(int id) async {
  final url = Uri.parse('${host}/workouts-sessions/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}

Future<WorkoutSummary> getWorkoutSummary(int idUser) async {
  final url = Uri.parse("${host}/workouts-sessions/${idUser}/summary");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final data = WorkoutSummary.fromJson(jsonResponse);
    return data;
  }
  throw response;
}