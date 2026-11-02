import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/data_transfer/data/repositories/data_transfer_repository_impl.dart';

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

void main() {
  weightImportTests();
  test('exports the backup as indented JSON', () async {
    final fake = FakeDio((_) => {'userId': 'u1', 'exerciseLogs': []});
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
    );

    final result = await repo.exportJson('u1');

    expect(result.getOrElse(() => ''), contains('"userId": "u1"'));
    expect(fake.seen.single.queryParameters, {'userId': 'u1'});
  });

  test('exports the sets as CSV text', () async {
    final fake = FakeDio((_) => 'date,exercise\n2026-10-01,Hack\n');
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
    );

    final result = await repo.exportCsv('u1');

    expect(result.getOrElse(() => ''), startsWith('date,exercise'));
  });

  test('sends the CSV and maps the import result', () async {
    final fake = FakeDio(
      (_) => {
        'imported': {'logs': 2, 'sets': 5},
        'skippedExisting': 1,
        'skippedRows': 3,
        'unmatchedExercises': ['Corrida'],
      },
    );
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
    );

    final result = await repo.importCsv('u1', 'a,b', unit: 'lb');

    final entity = result.getOrElse(() => throw StateError('no result'));
    expect(entity.logs, 2);
    expect(entity.sets, 5);
    expect(entity.skippedExisting, 1);
    expect(entity.skippedRows, 3);
    expect(entity.unmatchedExercises, ['Corrida']);
    expect(fake.seen.single.data, {'userId': 'u1', 'csv': 'a,b', 'unit': 'lb'});
  });

  test('sends the Hevy key to the Hevy import route', () async {
    final fake = FakeDio(
      (_) => {
        'imported': {'logs': 0, 'sets': 0},
      },
    );
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
    );

    await repo.importHevy('u1', 'secret');

    expect(fake.seen.single.path, 'imports/hevy');
    expect(fake.seen.single.data, {'userId': 'u1', 'apiKey': 'secret'});
  });

  test('sends the backup to the JSON import route', () async {
    final fake = FakeDio(
      (_) => {
        'imported': {'logs': 1, 'sets': 1},
      },
    );
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
    );

    final result = await repo.importJson('u1', {'exerciseLogs': []});

    expect(result.isRight(), isTrue);
    expect(fake.seen.single.path, 'imports/json');
  });

  test('turns a failed request into a failure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test/'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(requestOptions: options, message: 'offline'),
          ),
        ),
      );
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: dio),
    );

    final result = await repo.importHevy('u1', 'k');

    expect(result.isLeft(), isTrue);
    expect(
      result.swap().getOrElse(() => throw StateError('')),
      isA<ServerFailure>(),
    );
  });
}

void weightImportTests() {
  test('sends the weight file and maps the result', () async {
    final fake = FakeDio(
      (_) => {
        'format': 'apple-health',
        'imported': 3,
        'skippedExisting': 1,
        'skippedRows': 0,
      },
    );
    final repo = DataTransferRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
    );
    final result = await repo.importBodyWeight('u1', '<HealthData/>');
    final entity = result.getOrElse(() => throw StateError('no result'));
    expect(entity.format, 'apple-health');
    expect(entity.imported, 3);
    expect(entity.skippedExisting, 1);
    expect(fake.seen.single.path, 'imports/body-weight');
    expect(fake.seen.single.data, {
      'userId': 'u1',
      'data': '<HealthData/>',
      'unit': 'kg',
    });
  });
}
