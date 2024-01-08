import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user.dart';
import '../my_academy_api.dart';

Future<Users> getUsers() async {
  var url = Uri.parse("${host}/users");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Users.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Users> getUserById(int id) async {
  var url = Uri.parse("${host}/users/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Users.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Users> postUser(Users body) async {
  var url = Uri.parse("${host}/users");
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Users.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Users> putUser(Users body) async {
  var url = Uri.parse('${host}/users/${body.id}');
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Users.fromJson(jsonResponse);
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
