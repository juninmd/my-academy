// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_series_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutSeriesRepository)
final workoutSeriesRepositoryProvider = WorkoutSeriesRepositoryProvider._();

final class WorkoutSeriesRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutSeriesRepository,
          WorkoutSeriesRepository,
          WorkoutSeriesRepository
        >
    with $Provider<WorkoutSeriesRepository> {
  WorkoutSeriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSeriesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSeriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkoutSeriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutSeriesRepository create(Ref ref) {
    return workoutSeriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutSeriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutSeriesRepository>(value),
    );
  }
}

String _$workoutSeriesRepositoryHash() =>
    r'5b2269f51fe94d3b01a8eff765c864438f8f4cb6';

@ProviderFor(workoutSeries)
final workoutSeriesProvider = WorkoutSeriesProvider._();

final class WorkoutSeriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSeriesEntity>>,
          List<WorkoutSeriesEntity>,
          FutureOr<List<WorkoutSeriesEntity>>
        >
    with
        $FutureModifier<List<WorkoutSeriesEntity>>,
        $FutureProvider<List<WorkoutSeriesEntity>> {
  WorkoutSeriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSeriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSeriesHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSeriesEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSeriesEntity>> create(Ref ref) {
    return workoutSeries(ref);
  }
}

String _$workoutSeriesHash() => r'2a2b2bea1510fbcb094f69a841f3a05132cf4809';

@ProviderFor(workoutSeriesById)
final workoutSeriesByIdProvider = WorkoutSeriesByIdFamily._();

final class WorkoutSeriesByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSeriesEntity?>,
          WorkoutSeriesEntity?,
          FutureOr<WorkoutSeriesEntity?>
        >
    with
        $FutureModifier<WorkoutSeriesEntity?>,
        $FutureProvider<WorkoutSeriesEntity?> {
  WorkoutSeriesByIdProvider._({
    required WorkoutSeriesByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'workoutSeriesByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSeriesByIdHash();

  @override
  String toString() {
    return r'workoutSeriesByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSeriesEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSeriesEntity?> create(Ref ref) {
    final argument = this.argument as int;
    return workoutSeriesById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSeriesByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSeriesByIdHash() => r'31c265820eb7b0427f2c454301712824425c1aa4';

final class WorkoutSeriesByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkoutSeriesEntity?>, int> {
  WorkoutSeriesByIdFamily._()
    : super(
        retry: null,
        name: r'workoutSeriesByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutSeriesByIdProvider call(int id) =>
      WorkoutSeriesByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'workoutSeriesByIdProvider';
}
