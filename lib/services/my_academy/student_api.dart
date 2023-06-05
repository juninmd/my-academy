import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/student.dart';
import '../my_academy_api.dart';

Future<Student> getStudents() async {
  var url = Uri.parse("${host}/students");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Student.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Student> getStudentById(int id) async {
  var url = Uri.parse("${host}/students/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Student.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Student> postStudent(Student body) async {
  var url = Uri.parse("${host}/students");
  var response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Student.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Student> putStudent(Student body) async {
  var url = Uri.parse('${host}/students/${body.id}');
  var response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Student.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteStudent(int id) async {
  var url = Uri.parse('${host}/students/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
