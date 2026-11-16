import 'package:dio/dio.dart';

/// Answers every request from [responder] without touching the network.
class FakeDio {
  FakeDio(this.responder) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          seen.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              data: responder(options),
              statusCode: 200,
            ),
          );
        },
      ),
    );
  }

  final dynamic Function(RequestOptions options) responder;
  final List<RequestOptions> seen = [];
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/'));
}
