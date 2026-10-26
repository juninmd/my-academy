import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../exceptions/failure.dart';

class ApiClient {
  ApiClient({required String baseUrl, String? authToken, Dio? dio}) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
          ),
        );

    if (authToken != null) {
      setAuthToken(authToken);
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.d(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (e, handler) {
          logger.e(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            error: e.error,
            stackTrace: e.stackTrace,
          );
          return handler.next(e);
        },
      ),
    );
  }
  late final Dio _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        options: options,
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        options: options,
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        options: options,
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        options: options,
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure('Connection timed out');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('No internet connection');
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final message = serverMessage(e.response?.data);

      if (statusCode == 401) {
        return AuthFailure(message);
      }
      return ServerFailure(message, statusCode: statusCode);
    }

    return ServerFailure(e.message ?? 'Unknown error');
  }
}

/// Nest returns `message` as a string or, for validation errors, a list.
String serverMessage(Object? data) {
  if (data == null) return 'Unknown server error';

  if (data is Map) {
    final message = data['message'];
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join('\n');
    }
    if (message is String && message.trim().isNotEmpty) return message;

    final error = data['error'];
    if (error is String && error.trim().isNotEmpty) return error;
  }

  if (data is String && data.trim().isNotEmpty) return data;

  return 'Unknown server error';
}
