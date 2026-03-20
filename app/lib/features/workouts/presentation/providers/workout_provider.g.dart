// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutRepository)
final workoutRepositoryProvider = WorkoutRepositoryProvider._();

final class WorkoutRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutRepository,
          WorkoutRepository,
          WorkoutRepository
        >
    with $Provider<WorkoutRepository> {
  WorkoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkoutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutRepository create(Ref ref) {
    return workoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutRepository>(value),
    );
  }
}

String _$workoutRepositoryHash() => r'8706cff55254595fac99a2dae456ab881375a363';

@ProviderFor(workoutGroups)
final workoutGroupsProvider = WorkoutGroupsFamily._();

final class WorkoutGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutGroupEntity>>,
          List<WorkoutGroupEntity>,
          FutureOr<List<WorkoutGroupEntity>>
        >
    with
        $FutureModifier<List<WorkoutGroupEntity>>,
        $FutureProvider<List<WorkoutGroupEntity>> {
  WorkoutGroupsProvider._({
    required WorkoutGroupsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutGroupsHash();

  @override
  String toString() {
    return r'workoutGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutGroupEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutGroupEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return workoutGroups(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutGroupsHash() => r'e1ad66f630ce94969d8795664bd4397fc404936c';

final class WorkoutGroupsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutGroupEntity>>, String> {
  WorkoutGroupsFamily._()
    : super(
        retry: null,
        name: r'workoutGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutGroupsProvider call(String userId) =>
      WorkoutGroupsProvider._(argument: userId, from: this);

  @override
  String toString() => r'workoutGroupsProvider';
}
