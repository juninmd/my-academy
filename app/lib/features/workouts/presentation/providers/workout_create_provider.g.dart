// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_create_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutCreateNotifier)
final workoutCreateProvider = WorkoutCreateNotifierProvider._();

final class WorkoutCreateNotifierProvider
    extends $NotifierProvider<WorkoutCreateNotifier, WorkoutGroupEntity> {
  WorkoutCreateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutCreateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutCreateNotifierHash();

  @$internal
  @override
  WorkoutCreateNotifier create() => WorkoutCreateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutGroupEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutGroupEntity>(value),
    );
  }
}

String _$workoutCreateNotifierHash() =>
    r'fb8d92cfbf546118d154831835a98edbe7542855';

abstract class _$WorkoutCreateNotifier extends $Notifier<WorkoutGroupEntity> {
  WorkoutGroupEntity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WorkoutGroupEntity, WorkoutGroupEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutGroupEntity, WorkoutGroupEntity>,
              WorkoutGroupEntity,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(exercises)
final exercisesProvider = ExercisesProvider._();

final class ExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExerciseEntity>>,
          List<ExerciseEntity>,
          FutureOr<List<ExerciseEntity>>
        >
    with
        $FutureModifier<List<ExerciseEntity>>,
        $FutureProvider<List<ExerciseEntity>> {
  ExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exercisesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exercisesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExerciseEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExerciseEntity>> create(Ref ref) {
    return exercises(ref);
  }
}

String _$exercisesHash() => r'ee6ed55beda0ecd9c7a69c50d6c816a94b8ffa29';
