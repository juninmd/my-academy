import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/core/network/api_client.dart';
import 'package:my_academy/features/students/data/repositories/student_repository.dart';
import 'package:my_academy/features/students/domain/entities/student_entity.dart';

import 'student_repository_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late StudentRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = StudentRepositoryImpl(mockApiClient);
  });

  group('getStudents', () {
    test('should return list of students when successful', () async {
      final mockData = [
        {
          'id': '1',
          'name': 'Student 1',
          'email': 's1@test.com',
          'photoUrl': 'url1',
        },
        {
          'id': '2',
          'name': 'Student 2',
          'email': 's2@test.com',
          'photoUrl': 'url2',
        },
      ];

      when(
        mockApiClient.get('personals/trainer1/students'),
      ).thenAnswer((_) async => mockData);

      final result = await repository.getStudents('trainer1');

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (r) {
        expect(r.length, 2);
        expect(r[0].id, '1');
        expect(r[1].id, '2');
      });
    });

    test('should return failure when exception occurs', () async {
      when(mockApiClient.get(any)).thenThrow(Exception('Error'));

      final result = await repository.getStudents('trainer1');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should be left'),
      );
    });
  });

  group('addStudent', () {
    test('should return added student when successful', () async {
      const student = StudentEntity(id: '', name: 'New', email: 'new@test.com');

      final mockStudentSearchResponse = [
        {'id': '123', 'name': 'New', 'email': 'new@test.com', 'photoUrl': null},
      ];

      when(
        mockApiClient.get('users?email=new@test.com'),
      ).thenAnswer((_) async => mockStudentSearchResponse);

      when(
        mockApiClient.post('personals', data: anyNamed('data')),
      ).thenAnswer((_) async => {});

      final result = await repository.addStudent(student, 'trainer1');

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (r) => expect(r.id, '123'));
    });
  });

  group('checkStudentExists', () {
    test('should return student when found', () async {
      final mockResponse = [
        {'id': '123', 'name': 'New', 'email': 'new@test.com', 'photoUrl': null},
      ];
      when(
        mockApiClient.get('users?email=new@test.com'),
      ).thenAnswer((_) async => mockResponse);

      final result = await repository.checkStudentExists('new@test.com');
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (r) => expect(r?.id, '123'));
    });

    test('should return null when not found', () async {
      final mockResponse = [];
      when(
        mockApiClient.get('users?email=new@test.com'),
      ).thenAnswer((_) async => mockResponse);

      final result = await repository.checkStudentExists('new@test.com');
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (r) => expect(r, null));
    });
  });

  group('isPersonal', () {
    test('should return true when successful', () async {
      when(
        mockApiClient.get('personals?personalUserId=123'),
      ).thenAnswer((_) async => [{}]);
      final result = await repository.isPersonal('123');
      expect(result, true);
    });

    test('should return false when error', () async {
      when(
        mockApiClient.get('personals?personalUserId=123'),
      ).thenThrow(Exception());
      final result = await repository.isPersonal('123');
      expect(result, false);
    });
  });
}
