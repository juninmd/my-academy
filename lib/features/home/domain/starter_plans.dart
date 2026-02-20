import '../../workouts/domain/entities/exercise_entity.dart';
import '../../workouts/domain/entities/workout_entity.dart';
import '../../workouts/domain/entities/workout_group_entity.dart';
import '../../workouts/domain/entities/workout_series_entity.dart';

class StarterPlans {
  static List<WorkoutGroupEntity> getPlans(List<ExerciseEntity> allExercises) {
    // Helper to find exercise by fuzzy name
    ExerciseEntity? find(String keyword) {
      try {
        return allExercises.firstWhere(
          (e) => e.name.toLowerCase().contains(keyword.toLowerCase()),
        );
      } catch (e) {
        return null;
      }
    }

    final plans = <WorkoutGroupEntity>[];

    // 1. Full Body A
    final supino = find('Supino Reto') ?? find('Supino') ?? find('Chest');
    final agachamento = find('Agachamento') ?? find('Squat') ?? find('Leg Press');
    final remada = find('Remada') ?? find('Row') ?? find('Costas');
    final desenvolvimento = find('Desenvolvimento') ?? find('Press') ?? find('Ombros');

    if (supino != null && agachamento != null && remada != null) {
      plans.add(
        WorkoutGroupEntity(
          name: 'Full Body Iniciante',
          userId: '',
          image: 'assets/images/bg1.jpg', // Assuming this asset exists or use generic
          workouts: [
            _createWorkout(agachamento, 3, 10),
            _createWorkout(supino, 3, 10),
            _createWorkout(remada, 3, 12),
            if (desenvolvimento != null) _createWorkout(desenvolvimento, 2, 12),
          ],
        ),
      );
    }

    // 2. Upper Body
    final puxada = find('Puxada') ?? find('Pulldown');
    final elevacao = find('Elevação Lateral') ?? find('Lateral');
    final triceps = find('Tríceps') ?? find('Triceps');
    final biceps = find('Bíceps') ?? find('Biceps');

    if (supino != null && puxada != null) {
      plans.add(
        WorkoutGroupEntity(
          name: 'Superiores (Upper)',
          userId: '',
          image: 'assets/images/bg2.jpg',
          workouts: [
            _createWorkout(supino, 4, 8),
            _createWorkout(puxada, 4, 10),
            if (desenvolvimento != null) _createWorkout(desenvolvimento, 3, 10),
            if (elevacao != null) _createWorkout(elevacao, 3, 15),
            if (triceps != null) _createWorkout(triceps, 3, 12),
            if (biceps != null) _createWorkout(biceps, 3, 12),
          ],
        ),
      );
    }

    // 3. Lower Body
    final legPress = find('Leg Press');
    final extensora = find('Extensora');
    final flexora = find('Flexora');
    final panturrilha = find('Panturrilha');

    if ((agachamento != null || legPress != null) && extensora != null) {
      plans.add(
        WorkoutGroupEntity(
          name: 'Inferiores (Lower)',
          userId: '',
          image: 'assets/images/bg3.jpg',
          workouts: [
            _createWorkout(agachamento ?? legPress!, 4, 8),
            if (legPress != null && agachamento != null) _createWorkout(legPress, 3, 12),
            _createWorkout(extensora, 3, 15),
            if (flexora != null) _createWorkout(flexora, 4, 12),
            if (panturrilha != null) _createWorkout(panturrilha, 4, 15),
          ],
        ),
      );
    }

    return plans;
  }

  static WorkoutEntity _createWorkout(ExerciseEntity exercise, int sets, int reps) {
    return WorkoutEntity(
      exerciseId: exercise.id,
      exercise: exercise,
      series: List.generate(
        sets,
        (_) => WorkoutSeriesEntity(repetitions: reps, weight: 0, rest: 90),
      ),
    );
  }
}
