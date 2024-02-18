import '../../models/user.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Users>> getUsers() async {
  return await httpApi.request<Users>('get', 'users', Users.fromJson);
}

Future<Users> getUserById(int id) async {
  return await httpApi.request<Users>('get', 'users/${id}', Users.fromJson);
}

Future<Users> postUser(Users body) async {
  return await httpApi.request<Users>('post', 'users', Users.fromJson);
}

Future<Users> putUser(Users body) async {
  return  await httpApi.request<Users>('post', 'users/${body.id}', Users.fromJson);
}

Future<void> deleteUser(int id) async {
  return await httpApi.request<Users>('delete', 'users/${id}', Users.fromJson);
}
