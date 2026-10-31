import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/import_result_entity.dart';

abstract class DataTransferRepository {
  /// Full backup as pretty-printed JSON text.
  Future<Either<Failure, String>> exportJson(String userId);

  /// Workout sets as CSV text.
  Future<Either<Failure, String>> exportCsv(String userId);

  Future<Either<Failure, ImportResultEntity>> importCsv(
    String userId,
    String csv, {
    String unit = 'kg',
  });

  Future<Either<Failure, ImportResultEntity>> importJson(
    String userId,
    Map<String, dynamic> backup,
  );

  /// The key is sent once and not stored by the server.
  Future<Either<Failure, ImportResultEntity>> importHevy(
    String userId,
    String apiKey,
  );
}
