import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/entities/personal_entity.dart';
import '../../domain/repositories/personal_repository.dart';
import '../models/personal_dto.dart';

part 'personal_repository_impl.g.dart';

class PersonalRepositoryImpl implements PersonalRepository {
  PersonalRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<PersonalEntity>>> getPersonals({String? personalUserId}) async {
    try {
      final query = personalUserId != null ? '?personalUserId=$personalUserId' : '';
      final response = await _apiClient.get('personals$query');
      final List<dynamic> data = response;
      return Right(
        data
            .cast<Map<String, dynamic>>()
            .map((json) => PersonalDto.fromJson(json).toEntity())
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonalEntity>> createPersonal(PersonalEntity personal) async {
    try {
      final dto = PersonalDto.fromEntity(personal);
      final response = await _apiClient.post('personals', data: dto.toJson());
      return Right(
        PersonalDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonalEntity>> updatePersonal(PersonalEntity personal) async {
    try {
      final dto = PersonalDto.fromEntity(personal);
      final response = await _apiClient.patch('personals/${personal.id}', data: dto.toJson());
      return Right(
        PersonalDto.fromJson(response as Map<String, dynamic>).toEntity(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePersonal(int id) async {
    try {
      await _apiClient.delete('personals/$id');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

@riverpod
PersonalRepository personalRepository(Ref ref) {
  return PersonalRepositoryImpl(ref.watch(apiClientProvider));
}

@riverpod
Future<List<PersonalEntity>> personals(Ref ref, {String? personalUserId}) async {
  final repository = ref.watch(personalRepositoryProvider);
  final result = await repository.getPersonals(personalUserId: personalUserId);
  return result.fold((failure) => [], (list) => list);
}
