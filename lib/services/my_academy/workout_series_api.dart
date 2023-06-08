import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/workout_series.dart';
import '../my_academy_api.dart';

Future<WorkoutSeries> getWorkoutSeries() async {
  var url = Uri.parse("${host}/exercises-series");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = WorkoutSeries.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutSeries> getWorkoutSeriesById(int id) async {
  var url = Uri.parse("${host}/exercises-series/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = WorkoutSeries.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutSeries> postWorkoutSeries(WorkoutSeries body) async {
  var url = Uri.parse("${host}/exercises-series");
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = WorkoutSeries.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<WorkoutSeries> putWorkoutSeries(WorkoutSeries body) async {
  var url = Uri.parse('${host}/exercises-series/${body.id}');
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = WorkoutSeries.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteWorkoutSeries(int id) async {
  var url = Uri.parse('${host}/exercises-series/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
