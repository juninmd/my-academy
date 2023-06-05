import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/method.dart';
import '../my_academy_api.dart';

Future<Method> getMethods() async {
  var url = Uri.parse("${host}/methods");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Method> getMethodById(int id) async {
  var url = Uri.parse("${host}/methods/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Method> postMethod(Method exercise) async {
  var url = Uri.parse("${host}/methods");
  var response = await http.post(url, body: exercise);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Method> putMethod(Method exercise) async {
  var url = Uri.parse('${host}/methods/${exercise.id}');
  var response = await http.post(url, body: exercise);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteMethod(int id) async {
  var url = Uri.parse('${host}/methods/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
