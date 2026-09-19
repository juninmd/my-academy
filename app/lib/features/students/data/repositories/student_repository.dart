import '../../../../core/network/dio_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/student_entity.dart';

part 'student_repository.g.dart';

abstract class StudentRepository {
  Future<Either<Failure, List<StudentEntity>>> getStudents(String userId);
  Future<Either<Failure, StudentEntity>> addStudent(
    StudentEntity student,
    String personalId,
  );
  Future<Either<Failure, StudentEntity?>> checkStudentExists(String email);
  Future<bool> isPersonal(String userId);
}

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<StudentEntity>>> getStudents(
    String userId,
  ) async {
    try {
      final response = await _apiClient.get('personals/$userId/students');
      final List<dynamic> data = response;
      return Right(
        data
            .map((json) => _mapStudentFromPersonalItem(json))
            .whereType<StudentEntity>()
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> addStudent(
    StudentEntity student,
    String personalId,
  ) async {
    try {
      final existingResult = await checkStudentExists(student.email);
      final failureOrStudent = existingResult.fold(
        (left) => left,
        (right) => right,
      );
      if (failureOrStudent is Failure) {
        return Left(failureOrStudent);
      }
      final existingStudent = failureOrStudent as StudentEntity?;

      if (existingStudent == null) {
        return const Left(
          ServerFailure(
            'Aluno não encontrado. O aluno precisa acessar o app ao menos uma vez.',
          ),
        );
      }

      await _apiClient.post(
        'personals',
        data: {
          'personalUserId': personalId,
          'studentUserId': existingStudent.id,
        },
      );

      return Right(existingStudent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentEntity?>> checkStudentExists(
    String email,
  ) async {
    try {
      final response = await _apiClient.get(
        'users',
        queryParameters: {'email': email},
      );
      final List<dynamic> data = response;
      if (data.isNotEmpty) {
        final json = data.first;
        return Right(_mapStudentFromUser(json));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isPersonal(String userId) async {
    try {
      final response = await _apiClient.get(
        'personals',
        queryParameters: {'personalUserId': userId},
      );
      return response is List && response.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  StudentEntity? _mapStudentFromPersonalItem(dynamic item) {
    if (item is! Map<String, dynamic>) return null;
    final json = item;
    final student = json['student'];
    if (student is Map<String, dynamic>) {
      return _mapStudentFromUser(student);
    }
    if (json['id'] != null) {
      return _mapStudentFromUser(json);
    }
    return null;
  }

  StudentEntity _mapStudentFromUser(Map<String, dynamic> json) {
    return StudentEntity(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photoUrl: json['photoUrl']?.toString(),
    );
  }
}

@riverpod
StudentRepository studentRepository(Ref ref) =>
    StudentRepositoryImpl(ref.watch(apiClientProvider));

@riverpod
Future<List<StudentEntity>> students(Ref ref, String userId) async {
  final repo = ref.watch(studentRepositoryProvider);
  final result = await repo.getStudents(userId);
  return result.fold((failure) => throw failure, (r) => r);
}

@riverpod
Future<bool> isPersonal(Ref ref, String userId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.isPersonal(userId);
}
