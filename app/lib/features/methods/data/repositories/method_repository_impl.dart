import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/method_entity.dart';
import '../../domain/repositories/method_repository.dart';
import '../models/method_dto.dart';

part 'method_repository_impl.g.dart';

class MethodRepositoryImpl implements MethodRepository {
  MethodRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<MethodEntity>>> getMethods() async {
    try {
      final response = await _apiClient.get('methods');
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map((json) => MethodDto.fromJson(json).toEntity())
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MethodEntity>> getMethod(int id) async {
    try {
      final response = await _apiClient.get('methods/$id');
      final data = response as Map<String, dynamic>;
      return Right(MethodDto.fromJson(data).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MethodEntity>> createMethod(
    MethodEntity method,
  ) async {
    try {
      final dto = MethodDto.fromEntity(method);
      final response = await _apiClient.post('methods', data: dto.toJson());
      return Right(
        MethodDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MethodEntity>> updateMethod(
    MethodEntity method,
  ) async {
    try {
      final dto = MethodDto.fromEntity(method);
      final response = await _apiClient.patch(
        'methods/${method.id}',
        data: dto.toJson(),
      );
      return Right(
        MethodDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMethod(int id) async {
    try {
      await _apiClient.delete('methods/$id');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

@riverpod
MethodRepository methodRepository(Ref ref) {
  return MethodRepositoryImpl(ref.watch(apiClientProvider));
}

@riverpod
Future<List<MethodEntity>> methods(Ref ref) async {
  final repository = ref.watch(methodRepositoryProvider);
  final result = await repository.getMethods();
  return result.fold((failure) => [], (list) => list);
}

@riverpod
Future<MethodEntity?> method(Ref ref, int id) async {
  final repository = ref.watch(methodRepositoryProvider);
  final result = await repository.getMethod(id);
  return result.fold((failure) => null, (method) => method);
}
