import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_profile_sync.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, [this._profileSync]);
  final AuthRemoteDataSource _remoteDataSource;
  final UserProfileSync? _profileSync;

  Future<UserDto> _withProfile(UserDto identity) =>
      _profileSync?.sync(identity) ?? Future.value(identity);

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _withProfile(
        await _remoteDataSource.signInWithGoogle(),
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _withProfile(
        await _remoteDataSource.signInWithEmail(email, password),
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String? role,
  ) async {
    try {
      final user = await _withProfile(
        await _remoteDataSource.signUpWithEmail(email, password, role),
      );
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user == null ? null : await _withProfile(user));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDisplayName(String name) async {
    try {
      await _remoteDataSource.updateDisplayName(name);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
