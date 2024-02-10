import '../../models/method.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Method>> getMethods() {
  final url = 'methods';
  return httpApi.get<List<Method>>(url, Method.fromJson);
}

Future<Method> getMethodById(int id) {
  final url = 'methods/$id';
  return httpApi.get<Method>(url, Method.fromJson);
}

Future<Method> postMethod(Method body) {
  final url = 'methods';
  return httpApi.request<Method>('post', url, Method.fromJson, body: body);
}

Future<Method> putMethod(Method body) {
  final url = 'methods/${body.id}';
  return httpApi.request<Method>('put',url, Method.fromJson, body: body);
}

Future<void> deleteMethod(int id) async {
  final url = 'methods/$id';
  await httpApi.request('delete', url, null);
}
