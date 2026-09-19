import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers({required String email});
  Future<Either<Failure, UserEntity>> getUser(String id);
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);
  Future<Either<Failure, Unit>> deleteUser(String id);
}
