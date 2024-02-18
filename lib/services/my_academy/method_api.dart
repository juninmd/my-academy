import '../../models/method.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<List<Method>> getMethods()  async{
  return await httpApi.get<List<Method>>('methods', Method.fromJson);
}

Future<Method> getMethodById(int id) async {
  return await httpApi.get<Method>('methods/$id', Method.fromJson);
}

Future<Method> postMethod(Method body) async {
  return await httpApi.request<Method>('post', 'methods', Method.fromJson, body: body);
}

Future<Method> putMethod(Method body) async {
  return await httpApi.request<Method>('put','methods/${body.id}', Method.fromJson, body: body);
}

Future<void> deleteMethod(int id) async {
  await httpApi.request('delete', 'methods/$id', null);
}
