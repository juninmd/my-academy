import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/custom_exercise_repository.dart';

final customExerciseRepositoryProvider = Provider<CustomExerciseRepository>((
  ref,
) {
  return CustomExerciseRepository();
});
