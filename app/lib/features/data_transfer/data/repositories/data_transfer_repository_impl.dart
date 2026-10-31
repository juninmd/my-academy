import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/import_result_entity.dart';
import '../../domain/repositories/data_transfer_repository.dart';
import '../models/import_result_dto.dart';

class DataTransferRepositoryImpl implements DataTransferRepository {
  DataTransferRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, String>> exportJson(String userId) async {
    try {
      final data = await _apiClient.get(
        'export/json',
        queryParameters: {'userId': userId},
      );
      return Right(const JsonEncoder.withIndent('  ').convert(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportCsv(String userId) async {
    try {
      final data = await _apiClient.get(
        'export/csv',
        queryParameters: {'userId': userId},
      );
      return Right(data.toString());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ImportResultEntity>> importCsv(
    String userId,
    String csv, {
    String unit = 'kg',
  }) {
    return _post('imports/csv', {'userId': userId, 'csv': csv, 'unit': unit});
  }

  @override
  Future<Either<Failure, ImportResultEntity>> importJson(
    String userId,
    Map<String, dynamic> backup,
  ) {
    return _post('imports/json', {'userId': userId, 'data': backup});
  }

  @override
  Future<Either<Failure, ImportResultEntity>> importHevy(
    String userId,
    String apiKey,
  ) {
    return _post('imports/hevy', {'userId': userId, 'apiKey': apiKey});
  }

  Future<Either<Failure, ImportResultEntity>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _apiClient.post(path, data: body);
      return Right(ImportResultDto.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
