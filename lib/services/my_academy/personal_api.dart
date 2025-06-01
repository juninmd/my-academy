import '../../dto/student-dto.dart';
import '../../models/personal.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<Personal> getPersonals() async{
  return await httpApi.request<Personal>('get', 'personals', Personal.fromJson);
}

Future<Personal> getPersonalById(String id) async {
  return await httpApi.request<Personal>('get', 'personals/${id}', Personal.fromJson);
}

Future<Personal> postPersonal(Personal body) async {
  return await httpApi.request<Personal>('post', 'personals', Personal.fromJson,
      body: body);
}

Future<Personal> putPersonal(Personal body)  async{
  return await httpApi.request<Personal>(
      'put', 'personals/${body.id}', Personal.fromJson,
      body: body);
}

Future<void> deletePersonal(String id) async {
  return await httpApi.request<Personal>('delete', 'personals/${id}', null);
}

Future<List<StudentDto>> getStudents(personalId) async{
  return await httpApi.request<StudentDto>('get', 'personals/${personalId}/students', StudentDto.fromJson);
}

Future<Personal> postStudents(personalId, StudentDto body) async {
  return await httpApi.request<Personal>('post', 'personals/${personalId}/students', null,
      body: body);
}