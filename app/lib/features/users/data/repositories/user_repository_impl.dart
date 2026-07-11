import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_dto.dart';

part 'user_repository_impl.g.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({String? email}) async {
    try {
      final response = await _apiClient.get(
        'users',
        queryParameters: email != null ? {'email': email} : null,
      );
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map((json) => UserDto.fromJson(json).toEntity())
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUser(String id) async {
    try {
      final response = await _apiClient.get('users/$id');
      final data = response as Map<String, dynamic>;
      return Right(UserDto.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      final response = await _apiClient.post('users', data: dto.toJson());
      return Right(
        UserDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    try {
      final dto = UserDto.fromEntity(user);
      final response = await _apiClient.patch(
        'users/${user.id}',
        data: dto.toJson(),
      );
      return Right(
        UserDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String id) async {
    try {
      await _apiClient.delete('users/$id');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(ref.watch(apiClientProvider));
}

@riverpod
Future<List<UserEntity>> users(Ref ref, {String? email}) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUsers(email: email);
  return result.fold((failure) => [], (list) => list);
}

@riverpod
Future<UserEntity?> user(Ref ref, String id) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUser(id);
  return result.fold((failure) => null, (user) => user);
}
