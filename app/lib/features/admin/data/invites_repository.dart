import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/invite_entity.dart';
import 'models/invite_dto.dart';

/// Admin-only: creates and lists sign-up codes (`/invites`).
class InvitesRepository {
  InvitesRepository(this._apiClient);
  final ApiClient _apiClient;

  Future<Either<Failure, List<InviteEntity>>> list() async {
    try {
      final response = await _apiClient.get('invites') as List<dynamic>;
      return Right(
        response
            .cast<Map<String, dynamic>>()
            .map(InviteDto.fromJson)
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Returns the new code, which is shown once to the admin.
  Future<Either<Failure, String>> create({int validityDays = 7}) async {
    try {
      final response = await _apiClient.post(
        'invites',
        data: {'validityDays': validityDays},
      ) as Map<String, dynamic>;
      return Right(response['code'] as String);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
