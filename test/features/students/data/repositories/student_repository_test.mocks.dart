import 'package:mockito/mockito.dart';
import 'package:my_academy/core/network/api_client.dart';

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<dynamic> get(String? path, {Map<String, dynamic>? queryParameters}) =>
      super.noSuchMethod(
        Invocation.method(#get, [path], {#queryParameters: queryParameters}),
        returnValue: Future.value([]),
      );

  @override
  Future<dynamic> post(String? path, {dynamic data}) => super.noSuchMethod(
        Invocation.method(#post, [path], {#data: data}),
        returnValue: Future.value({}),
      );

  @override
  Future<dynamic> put(String? path, {dynamic data}) => super.noSuchMethod(
        Invocation.method(#put, [path], {#data: data}),
        returnValue: Future.value({}),
      );

  @override
  Future<dynamic> delete(String? path) => super.noSuchMethod(
        Invocation.method(#delete, [path]),
        returnValue: Future.value({}),
      );
}
