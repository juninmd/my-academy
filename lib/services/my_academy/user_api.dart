import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user.dart';
import '../my_academy_api.dart';

Future<User> getUsers() async {
  var url = Uri.parse("${host}/users");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = User.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<User> getUserById(int id) async {
  var url = Uri.parse("${host}/users/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = User.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<User> postUser(User body) async {
  var url = Uri.parse("${host}/users");
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = User.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<User> putUser(User body) async {
  var url = Uri.parse('${host}/users/${body.id}');
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = User.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteUser(int id) async {
  var url = Uri.parse('${host}/users/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
