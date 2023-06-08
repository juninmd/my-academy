import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/personal.dart';
import '../my_academy_api.dart';

Future<Personal> getPersonals() async {
  var url = Uri.parse("${host}/personals");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Personal.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Personal> getPersonalById(int id) async {
  var url = Uri.parse("${host}/personals/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Personal.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Personal> postPersonal(Personal body) async {
  var url = Uri.parse("${host}/personals");
  var response = await http.post(url,body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Personal.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Personal> putPersonal(Personal body) async {
  var url = Uri.parse('${host}/personals/${body.id}');
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Personal.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deletePersonal(int id) async {
  var url = Uri.parse('${host}/personals/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
