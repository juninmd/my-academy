import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_dto.dart';

/// Merges the authenticated identity with the backend profile (role, name),
/// registering the user on first access.
class UserProfileSync {
  UserProfileSync(this._apiClient);
  final ApiClient _apiClient;

  Future<UserDto> sync(UserDto identity) async {
    try {
      final json = await _apiClient.get('users/${identity.id}');
      return UserDto.fromJson(json as Map<String, dynamic>);
    } on ServerFailure catch (e) {
      if (e.statusCode != 404) rethrow;
      final created = await _apiClient.post('users', data: identity.toJson());
      return UserDto.fromJson(created as Map<String, dynamic>);
    } on NetworkFailure catch (e) {
      logger.w('Profile sync skipped (offline): ${e.message}');
      return identity;
    }
  }

  Future<void> markOnboarded(String userId) =>
      _apiClient.patch('users/$userId', data: {'onboarded': true});

  Future<UserDto> updateRole(String userId, String role) async {
    final json = await _apiClient.patch('users/$userId', data: {'role': role});
    return UserDto.fromJson(json as Map<String, dynamic>);
  }
}
