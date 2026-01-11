import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../utils/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/workout_session_entity.dart';

part 'calendar_repository.g.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<WorkoutSessionEntity>>> getSessions(
    String userId,
    int month,
    int year,
  );
}

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<WorkoutSessionEntity>>> getSessions(
    String userId,
    int month,
    int year,
  ) async {
    try {
      final response = await _apiClient.get(
        'workouts-sessions/$userId?month=$month&year=$year',
      );
      final List<dynamic> data = response;
      return Right(
        data
            .map(
              (json) => WorkoutSessionEntity(
                id: json['id'],
                workoutGroupId: json['workoutGroupId'],
                date: DateTime.parse(json['date']),
                checked: json['checked'] ?? false,
                userId: json['userId'] ?? userId,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

@riverpod
CalendarRepository calendarRepository(Ref ref) =>
    CalendarRepositoryImpl(ref.watch(apiClientProvider));

@riverpod
Future<List<WorkoutSessionEntity>> workoutSessions(
  Ref ref,
  String userId,
  int month,
  int year,
) async {
  final repository = ref.watch(calendarRepositoryProvider);
  final result = await repository.getSessions(userId, month, year);
  return result.fold((failure) => [], (list) => list);
}
