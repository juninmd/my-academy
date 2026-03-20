import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/workout_summary_entity.dart';
import '../../domain/repositories/home_repository.dart';

part 'home_provider.g.dart';

@riverpod
HomeRemoteDataSource homeRemoteDataSource(Ref ref) => HomeRemoteDataSourceImpl(
  ref.watch(apiClientProvider),
  ref.watch(authRemoteDataSourceProvider),
);

@riverpod
HomeRepository homeRepository(Ref ref) =>
    HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider));

@riverpod
Future<WorkoutSummaryEntity> workoutSummary(Ref ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.getWorkoutSummary();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (summary) => summary,
  );
}
