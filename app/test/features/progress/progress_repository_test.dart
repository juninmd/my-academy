import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/progress/data/repositories/progress_repository_impl.dart';

import 'fake_dio.dart';

void main() {
  ProgressRepositoryImpl repoFor(FakeDio fake) => ProgressRepositoryImpl(
    ApiClient(baseUrl: 'http://api.test/', dio: fake.dio),
  );

  test('reads the suggestion for an exercise', () async {
    final fake = FakeDio(
      (_) => {
        'exerciseId': 7,
        'strategy': 'double',
        'suggestion': {
          'weight': 52.5,
          'reps': 8,
          'sets': 3,
          'deload': false,
          'reason': 'Top of the rep range reached.',
        },
      },
    );

    final result = await repoFor(fake).getSuggestion('u1', 7);

    final s = result.getOrElse(() => throw StateError('no result'))!;
    expect(s.weight, 52.5);
    expect(s.reps, 8);
    expect(s.sets, 3);
    expect(s.deload, isFalse);
    expect(fake.seen.single.path, 'progress/exercises/7/suggestion');
  });

  test('returns null without history', () async {
    final fake = FakeDio(
      (_) => {'exerciseId': 7, 'strategy': 'double', 'suggestion': null},
    );
    final result = await repoFor(fake).getSuggestion('u1', 7);
    expect(result.getOrElse(() => throw StateError('')), isNull);
  });

  test('asks the coach for advice and returns the text', () async {
    final fake = FakeDio(
      (_) => {'advice': 'Chest is ahead of back.', 'days': 30},
    );

    final result = await repoFor(fake).getCoachAdvice('u1', days: 14);

    expect(result.getOrElse(() => ''), 'Chest is ahead of back.');
    expect(fake.seen.single.method, 'POST');
    expect(fake.seen.single.data, {'userId': 'u1', 'days': 14});
  });

  test('turns a failed coach call into a failure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://api.test/'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(requestOptions: options, message: 'AI coach is off'),
          ),
        ),
      );
    final repo = ProgressRepositoryImpl(
      ApiClient(baseUrl: 'http://api.test/', dio: dio),
    );

    final result = await repo.getCoachAdvice('u1');

    expect(
      result.swap().getOrElse(() => throw StateError('')),
      isA<ServerFailure>(),
    );
  });
}
