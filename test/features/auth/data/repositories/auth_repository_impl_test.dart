import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:my_academy/features/auth/data/models/user_dto.dart';
import 'package:my_academy/features/auth/data/repositories/auth_repository_impl.dart';

@GenerateNiceMocks([MockSpec<AuthRemoteDataSource>()])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  const userDto = UserDto(id: '1', email: 'email', name: 'name', photoUrl: 'url');

  group('signInWithGoogle', () {
    test('should return user when successful', () async {
      when(mockDataSource.signInWithGoogle()).thenAnswer((_) async => userDto);
      final result = await repository.signInWithGoogle();
      expect(result, const Right(userDto));
    });

    test('should return failure when exception occurs', () async {
      when(mockDataSource.signInWithGoogle()).thenThrow(const AuthFailure('error'));
      final result = await repository.signInWithGoogle();
      expect(result, const Left(AuthFailure('error')));
    });
  });

  group('signOut', () {
    test('should return void when successful', () async {
      when(mockDataSource.signOut()).thenAnswer((_) async {});
      final result = await repository.signOut();
      expect(result, const Right(null));
    });

    test('should return failure when exception occurs', () async {
      when(mockDataSource.signOut()).thenThrow(const AuthFailure('error'));
      final result = await repository.signOut();
      expect(result, const Left(AuthFailure('error')));
    });
  });

  group('getCurrentUser', () {
    test('should return user when successful', () async {
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => userDto);
      final result = await repository.getCurrentUser();
      expect(result, const Right(userDto));
    });

     test('should return null when no user', () async {
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => null);
      final result = await repository.getCurrentUser();
      expect(result, const Right(null));
    });

    test('should return failure when exception occurs', () async {
      when(mockDataSource.getCurrentUser()).thenThrow(const AuthFailure('error'));
      final result = await repository.getCurrentUser();
      expect(result, const Left(AuthFailure('error')));
    });
  });
}
