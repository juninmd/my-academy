import '../../models/user.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Users>> getUsers() async {
  return await httpApi.request<Users>('get', 'users', Users.fromJson);
}

Future<Users> getUserById(String id) async {
  return await httpApi.request<Users>('get', 'users/${id}', Users.fromJson);
}

Future<Users> getUserByEmail(String email) async {
  return await httpApi.request<Users>('get', 'users/email/${email}', Users.fromJson);
}

Future<void> postUser(Users body) async {
  await httpApi.request<Users>('post', 'users', null, body: body);
}

Future<Users> putUser(Users body) async {
  return await httpApi
      .request<Users>('put', 'users/${body.id}', Users.fromJson, body: body);
}

Future<void> deleteUser(String id) async {
  return await httpApi.request<Users>('delete', 'users/${id}', Users.fromJson);
}
