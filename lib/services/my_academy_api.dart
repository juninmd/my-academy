import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/exercise.dart';

const host = 'http://localhost:9000';

class HttpApi {
  Duration duration = Duration(seconds: 5);

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

  Future<T> requestBase<T>(String method, String url,
      dynamic Function(Map<String, dynamic> data)? fromJson,
      {Object? body}) async {
    final uri = Uri.parse('$host/$url');
    var response;

    switch (method) {
      case 'get':
        response =
            await http.get(uri, headers: await _getHeaders()).timeout(duration);
        break;
      case 'post':
        response = await http
            .post(uri, body: body, headers: await _getHeaders())
            .timeout(duration);
        break;
      case 'put':
        response = await http
            .put(uri, body: body, headers: await _getHeaders())
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

  Future<T> get<T>(String url,
          dynamic Function(Map<String, dynamic> data) fromJson) async =>
      request<T>('get', url, fromJson);

  Future<T> post<T>(
          String url, dynamic Function(Map<String, dynamic> data) fromJson,
          {Object? body}) async =>
      request<T>('post', url, fromJson, body: body);

  Future<T> put<T>(
          String url, dynamic Function(Map<String, dynamic> data) fromJson,
          {Object? body}) async =>
      request<T>('put', url, fromJson, body: body);

  Future<void> delete(String url) async {
    var uri = Uri.parse("$host/$url");
    await http.delete(uri, headers: await _getHeaders()).timeout(duration);
  }

  Future<T> patch<T>(
          String url, dynamic Function(Map<String, dynamic> data) fromJson,
          {Object? body}) async =>
      request<T>('patch', url, fromJson, body: body);

  Future<Map<String, String>> _getHeaders() async {
    final firebaseAuthToken = await getAuth();
    return {'Authorization': 'Bearer $firebaseAuthToken'};
  }
}
