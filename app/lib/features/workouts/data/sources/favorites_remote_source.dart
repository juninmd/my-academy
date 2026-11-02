import '../../../../core/network/api_client.dart';

/// Favourite exercises kept on the server, so they follow the user across devices.
class FavoritesRemoteSource {
  FavoritesRemoteSource(this._apiClient);
  final ApiClient _apiClient;

  Future<Set<int>> list(String userId) async {
    final response = await _apiClient.get(
      'favorites',
      queryParameters: {'userId': userId},
    ) as List<dynamic>;
    return response
        .map((e) => (e as Map<String, dynamic>)['id'] as int)
        .toSet();
  }

  Future<void> add(String userId, int exerciseId) async {
    await _apiClient.post(
      'favorites',
      data: {'userId': userId, 'exerciseId': exerciseId},
    );
  }

  Future<void> remove(String userId, int exerciseId) async {
    await _apiClient.delete(
      'favorites/$exerciseId',
      queryParameters: {'userId': userId},
    );
  }
}
