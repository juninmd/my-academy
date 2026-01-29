import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/calendar/data/repositories/calendar_repository.dart';

@GenerateNiceMocks([MockSpec<ApiClient>()])
import 'calendar_repository_test.mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late CalendarRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = CalendarRepositoryImpl(mockApiClient);
  });

  group('getSessions', () {
    test('should return list of sessions when successful', () async {
      final mockData = [
        {
          'id': '1',
          'workoutGroupId': 1,
          'date': '2023-01-01T00:00:00.000Z',
          'checked': true,
          'userId': 'u1',
        }
      ];

      when(mockApiClient.get(any)).thenAnswer((_) async => mockData);

      final result = await repository.getSessions('u1', 1, 2023);

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('should be right'),
        (r) {
          expect(r.length, 1);
          expect(r[0].id, '1');
        },
      );
    });

    test('should return failure when exception', () async {
      when(mockApiClient.get(any)).thenThrow(Exception('error'));

      final result = await repository.getSessions('u1', 1, 2023);

      expect(result.isLeft(), true);
    });
  });
}
