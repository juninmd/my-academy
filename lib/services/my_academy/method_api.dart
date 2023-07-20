import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/method.dart';
import '../my_academy_api.dart';

Future<List<Method>> getMethods() async {
  var url = Uri.parse("${host}/methods");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body) as List<dynamic>;
    final methods = jsonResponse.map((data) {
      return Method.fromJson(data);
    }).toList();
    return methods.toList();
  }
  throw response;
}

Future<Method> getMethodById(int id) async {
  var url = Uri.parse("${host}/methods/${id}");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Method> postMethod(Method body) async {
  var url = Uri.parse("${host}/methods");
  var response = await http.post(url, body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<Method> putMethod(Method body) async {
  var url = Uri.parse('${host}/methods/${body.id}');
  var response = await http.post(url,body: jsonEncode(body));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var data = Method.fromJson(jsonResponse);
    return data;
  }
  throw response;
}

Future<void> deleteMethod(int id) async {
  var url = Uri.parse('${host}/methods/${id}');
  final response = await http.delete(url);

  if (response.statusCode == 200) {
    return;
  }
  throw response;
}
