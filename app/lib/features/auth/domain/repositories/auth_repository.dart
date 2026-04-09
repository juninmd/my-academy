import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmail(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> updateDisplayName(String name);
}
