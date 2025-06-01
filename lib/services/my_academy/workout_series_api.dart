import '../../models/workout_series.dart';
import '../my_academy_api.dart';

var httpApi = HttpApi();

Future<WorkoutSeries> getWorkoutSeries() async {
  return await httpApi.request<WorkoutSeries>('get', 'workouts-series', WorkoutSeries.fromJson);
}

Future<WorkoutSeries> getWorkoutSeriesById(int id) async {
  return await httpApi.request<WorkoutSeries>('get', 'workouts-series/${id}', WorkoutSeries.fromJson);
}

Future<WorkoutSeries> postWorkoutSeries(WorkoutSeries body) async {
  return await httpApi.request<WorkoutSeries>('post', 'workouts-series', WorkoutSeries.fromJson, body: body);
}

Future<WorkoutSeries> putWorkoutSeries(WorkoutSeries body) async {
  return await httpApi.request<WorkoutSeries>('put', 'workouts-series/${body.id}', WorkoutSeries.fromJson, body: body);
}

Future<void> deleteWorkoutSeries(int id) async {
  return await httpApi.request<WorkoutSeries>('delete', 'workouts-series/${id}', WorkoutSeries.fromJson);
}
