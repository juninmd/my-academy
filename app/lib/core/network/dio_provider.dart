import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_client.dart';

const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:9000/api/');

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (e) {
          debugPrint('Error getting auth token: $e');
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        // Could handle 401 refresh here if using custom auth,
        // but Firebase clientSDK handles token refresh automatically.
        return handler.next(e);
      },
    ),
  );

  if (kDebugMode) {
    // dio.interceptors.add(
    //   PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseHeader: false,
    //   ),
    // );
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  // BaseUrl is already set in Dio options, but ApiClient might overwrite it if we pass it.
  // We'll pass the Dio instance which already has the BaseOptions.
  return ApiClient(baseUrl: _getBaseUrl(), dio: dio);
});

String _getBaseUrl() {
  // If the env variable is set and not the default fallback
  final envUrl = _apiBaseUrlFromEnv.trim();
  if (envUrl.isNotEmpty && envUrl != 'http://localhost:9000/api/') {
    return envUrl;
  }

  if (kReleaseMode) {
    return 'https://my-academy-api.onrender.com';
  }

  if (kIsWeb) return 'http://localhost:9000/api/';

  // Android Emulator
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:9000/api/';
  }

  // iOS Simulator
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return 'http://localhost:9000/api/';
  }

  // Fallback
  return _apiBaseUrlFromEnv;
}
