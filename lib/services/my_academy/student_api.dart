import '../../models/student.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<Student> getStudents() async {
  return await httpApi.request<Student>('get', 'students', Student.fromJson);
}

Future<Student> getStudentById(int id) async {
  return await httpApi.request<Student>('get', 'students/${id}', Student.fromJson);
}

Future<Student> postStudent(Student body) async {
  return await httpApi.request<Student>('post', 'students', Student.fromJson,
      body: body);
}

Future<Student> putStudent(Student body) async {
  return await httpApi.request<Student>('put', 'students/${body.id}', Student.fromJson,
      body: body);
}

Future<void> deleteStudent(int id) async {
  return await httpApi.request<Student>('delete', 'students/${id}', Student.fromJson);
}
