import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/core/exceptions/failure.dart';

@GenerateNiceMocks([MockSpec<Dio>(), MockSpec<Interceptors>()])
import 'api_client_test.mocks.dart';

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;
  late MockInterceptors mockInterceptors;

  setUp(() {
    mockDio = MockDio();
    mockInterceptors = MockInterceptors();

    when(mockDio.options).thenReturn(BaseOptions());
    when(mockDio.interceptors).thenReturn(mockInterceptors);

    apiClient = ApiClient(baseUrl: 'https://example.com', dio: mockDio);
  });

  group('ApiClient', () {
    test('get call should return data when successful', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'test'),
          data: {'key': 'value'},
          statusCode: 200,
        ),
      );

      final result = await apiClient.get('test');
      expect(result, {'key': 'value'});
    });

    test('get call should throw ServerFailure on DioException', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'test'),
          response: Response(
            requestOptions: RequestOptions(path: 'test'),
            statusCode: 500,
            data: {'message': 'Server Error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(() => apiClient.get('test'), throwsA(isA<ServerFailure>()));
    });

    test('get call should parse list of error messages', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'test'),
          response: Response(
            requestOptions: RequestOptions(path: 'test'),
            statusCode: 400,
            data: {'message': ['Bad request 1', 'Bad request 2']},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => apiClient.get('test'),
        throwsA(isA<ServerFailure>().having((e) => e.message, 'message', 'Bad request 1\nBad request 2')),
      );
    });

    test('get call should parse error property if message is null', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: 'test'),
          response: Response(
            requestOptions: RequestOptions(path: 'test'),
            statusCode: 500,
            data: {'error': 'Internal Server Error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => apiClient.get('test'),
        throwsA(isA<ServerFailure>().having((e) => e.message, 'message', 'Internal Server Error')),
      );
    });

    test('post call should return data when successful', () async {
      when(
        mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'test'),
          data: {'key': 'value'},
          statusCode: 200,
        ),
      );

      final result = await apiClient.post('test', data: {});
      expect(result, {'key': 'value'});
    });

    test('put call should return data when successful', () async {
      when(
        mockDio.put(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'test'),
          data: {'key': 'value'},
          statusCode: 200,
        ),
      );

      final result = await apiClient.put('test', data: {});
      expect(result, {'key': 'value'});
    });

    test('delete call should return data when successful', () async {
      when(
        mockDio.delete(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'test'),
          data: {'key': 'value'},
          statusCode: 200,
        ),
      );

      final result = await apiClient.delete('test');
      expect(result, {'key': 'value'});
    });

    test('setAuthToken should set Authorization header', () {
      apiClient.setAuthToken('token');
      expect(mockDio.options.headers['Authorization'], 'Bearer token');
    });

    test('clearAuthToken should remove Authorization header', () {
      apiClient.setAuthToken('token');
      apiClient.clearAuthToken();
      expect(mockDio.options.headers.containsKey('Authorization'), false);
    });
  });

  group('serverMessage', () {
    test('returns Unknown server error for null data', () {
      expect(serverMessage(null), 'Unknown server error');
    });

    test('returns message when it is a non-empty string', () {
      expect(serverMessage({'message': 'Error msg'}), 'Error msg');
    });

    test('returns joined message when it is a non-empty list', () {
      expect(
        serverMessage({'message': ['Error 1', 'Error 2']}),
        'Error 1\nError 2',
      );
    });

    test('falls back to error when message is an empty list', () {
      expect(
        serverMessage({'message': [], 'error': 'Fallback error'}),
        'Fallback error',
      );
    });

    test('falls back to error when message is a whitespace string', () {
      expect(
        serverMessage({'message': '   ', 'error': 'Fallback error'}),
        'Fallback error',
      );
    });

    test('returns Unknown server error when map is empty', () {
      expect(serverMessage({}), 'Unknown server error');
    });

    test('returns the string itself if data is a non-empty string', () {
      expect(serverMessage('Direct string error'), 'Direct string error');
    });

    test('returns Unknown server error if data is a whitespace string', () {
      expect(serverMessage('   '), 'Unknown server error');
    });
  });
}
