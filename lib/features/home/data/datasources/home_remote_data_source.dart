import '../../../../core/network/api_client.dart';
import '../../../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../../../utils/constants.dart';
import '../../domain/entities/workout_summary_entity.dart';

abstract class HomeRemoteDataSource {
  Future<WorkoutSummaryEntity> getWorkoutSummary();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this._apiClient, this._authDataSource);
  final ApiClient _apiClient;
  final AuthRemoteDataSource _authDataSource;

  @override
  Future<WorkoutSummaryEntity> getWorkoutSummary() async {
    final user = await _authDataSource.getCurrentUser();
    if (user == null) throw Exception('User not logged in');

    // Using the legacy DTO structure for now as API response
    final response = await _apiClient.get(
      'workouts-sessions/${user.id}/summary',
    );

    // Map response to Entity manually or via DTO
    // Assuming response structure matches legacy WorkoutSummary
    final counter = response['counter'] ?? 0;
    final lastSession = response['lastSession'];
    final workoutGroupOfDay = response['workoutGroupOfDay'];
    final personal = response['personal'];

    String? lastDate;
    String? wName;
    if (lastSession != null) {
      // date parsing might be needed depending on API format
      lastDate = lastSession['date'];
      if (lastSession['workoutsGroups'] != null) {
        wName = lastSession['workoutsGroups']['name'];
      }
    }

    return WorkoutSummaryEntity(
      counter: counter,
      lastSessionDate: lastDate,
      workoutName: wName,
      personalName: personal != null ? personal['name'] : null,
      workoutGroupId: workoutGroupOfDay != null ? workoutGroupOfDay['id'] : null,
      hasWorkoutToday: workoutGroupOfDay != null,
    );
  }
}
