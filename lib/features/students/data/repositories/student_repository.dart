import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../utils/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/student_entity.dart';

part 'student_repository.g.dart';

abstract class StudentRepository {
  Future<Either<Failure, List<StudentEntity>>> getStudents(String userId);
  Future<Either<Failure, StudentEntity>> addStudent(StudentEntity student, String personalId);
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
      // Changed to use query parameter on /students resource
      final response = await _apiClient.get('students?personalId=$userId');
      final List<dynamic> data = response;
      return Right(
        data.map((json) {
          // Flattened structure from /students
          return StudentEntity(
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            email: json['email'] ?? '',
            photoUrl: json['photoUrl'],
          );
        }).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> addStudent(StudentEntity student, String personalId) async {
    try {
      final data = {
        'name': student.name,
        'email': student.email,
        'photoUrl': student.photoUrl,
        'personalId': personalId,
      };

      // Post to /students to create a new record
      final response = await _apiClient.post('students', data: data);

      return Right(StudentEntity(
        id: response['id'] ?? '',
        name: response['name'] ?? '',
        email: response['email'] ?? '',
        photoUrl: response['photoUrl'],
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentEntity?>> checkStudentExists(String email) async {
    try {
      final response = await _apiClient.get('students?email=$email');
      final List<dynamic> data = response;
      if (data.isNotEmpty) {
        final json = data.first;
        return Right(StudentEntity(
          id: json['id'] ?? '',
          name: json['name'] ?? '',
          email: json['email'] ?? '',
          photoUrl: json['photoUrl'],
        ));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isPersonal(String userId) async {
    // Check if user exists in 'personals' table
    try {
      await _apiClient.get('personals/$userId');
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
StudentRepository studentRepository(Ref ref) =>
    StudentRepositoryImpl(ref.watch(apiClientProvider));

@riverpod
Future<List<StudentEntity>> students(Ref ref, String userId) async {
  final repo = ref.watch(studentRepositoryProvider);
  final result = await repo.getStudents(userId);
  return result.fold((l) => [], (r) => r);
}

@riverpod
Future<bool> isPersonal(Ref ref, String userId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.isPersonal(userId);
}
