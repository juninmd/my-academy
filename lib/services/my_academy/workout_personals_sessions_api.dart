import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/workout_personal_session.dart';
import '../my_academy_api.dart';

Future<List<WorkoutPersonalSession>> getStudentsSessions(idUser) async {
  final url =
      Uri.parse("${host}/workouts-personals-sessions/students/${idUser}");
  final response = await http.get(url).timeout(const Duration(seconds: 5));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body) as List<dynamic>;
    final payload = jsonResponse.map((data) {
      return WorkoutPersonalSession.fromJson(data);
    }).toList();
    return payload;
  }
  throw response;
}
