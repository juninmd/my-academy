import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/domain/repositories/workout_repository.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

@GenerateNiceMocks([MockSpec<WorkoutRepository>()])
import 'workout_provider_test.mocks.dart';

class MockAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  MockAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
  });

  const user = UserEntity(id: 'u1', email: 'e', name: 'n');

  test('workoutGroups provider returns groups when success', () async {
    final groups = [const WorkoutGroupEntity(id: 1, name: 'g1', userId: 'u1', workouts: [])];
    when(mockRepository.getWorkoutGroups('u1')).thenAnswer((_) async => Right(groups));

    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    final sub = container.listen(workoutGroupsProvider('u1').future, (_, _) {});

    expect(
      await container.read(workoutGroupsProvider('u1').future),
      groups,
    );

    sub.close();
  });

  test('workoutGroupByIdProvider returns group when found', () async {
    final group = const WorkoutGroupEntity(id: 1, name: 'g1', userId: 'u1', workouts: []);
    when(mockRepository.getWorkoutGroup(any, any)).thenAnswer((_) async => Right(group));

    final container = ProviderContainer(
      overrides: [
         authProvider.overrideWith(() => MockAuthNotifier(user)),
         workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    final sub = container.listen(workoutGroupByIdProvider(1).future, (_, _) {});

    expect(
      await container.read(workoutGroupByIdProvider(1).future),
      group,
    );

    sub.close();
  });
}
