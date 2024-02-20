import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const host = 'http://localhost:9000';

class HttpApi {
  Duration duration = Duration(seconds: 15);

  Future<String> getAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    final idTokenResult = await user!.getIdTokenResult();
    final token = idTokenResult.token;
    return token!;
  }

  dynamic _processResponse<T>(http.Response response, fromJson) {
    if (response.statusCode >= 200 && response.statusCode <= 300) {
      var decodedJson = json.decode(response.body);
      if (fromJson == null) {
        return null;
      }

      var isList = decodedJson is List;

      if (isList) {
        var responseJson = <T>[];

        final jsonResponse = json.decode(response.body) as List<dynamic>;
        jsonResponse.forEach((data) {
          responseJson.add(fromJson(data));
        });

        return responseJson;
      }
      var jsonData = fromJson(decodedJson);
      return jsonData;
    }
    throw response;
  }

  Future<http.Response> requestBase<T>(String method, String url,
      dynamic Function(Map<String, dynamic> data)? fromJson,
      {body}) async {
    final uri = Uri.parse('$host/$url');
    http.Response response;

    if (body != null) {
      body = jsonEncode(body.toJson());
    }

    switch (method) {
      case 'get':
        response =
            await http.get(uri, headers: await _getHeaders()).timeout(duration);
        break;
      case 'post':
        response = await http
            .post(uri, body: body, encoding: utf8, headers: await _getHeaders())
            .timeout(duration);
        break;
      case 'put':
        response = await http
            .put(uri, body: body, encoding: utf8, headers: await _getHeaders())
            .timeout(duration);
        break;
      case 'delete':
        response = await http
            .delete(uri, headers: await _getHeaders())
            .timeout(duration);
        break;
      default:
        response =
            await http.get(uri, headers: await _getHeaders()).timeout(duration);
        break;
    }
    return response;
  }

  request<T>(String method, String url,
      dynamic Function(Map<String, dynamic> data)? fromJson,
      {Object? body}) async {
    var response = await requestBase(method, url, fromJson, body: body);

    var processed = await _processResponse<T>(response, fromJson);
    return processed;
  }

  Future<Map<String, String>> _getHeaders() async {
    final firebaseAuthToken = await getAuth();

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $firebaseAuthToken'
    };
  }
}
