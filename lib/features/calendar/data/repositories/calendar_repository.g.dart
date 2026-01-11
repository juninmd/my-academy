// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(calendarRepository)
final calendarRepositoryProvider = CalendarRepositoryProvider._();

final class CalendarRepositoryProvider
    extends
        $FunctionalProvider<
          CalendarRepository,
          CalendarRepository,
          CalendarRepository
        >
    with $Provider<CalendarRepository> {
  CalendarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarRepositoryHash();

  @$internal
  @override
  $ProviderElement<CalendarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarRepository create(Ref ref) {
    return calendarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarRepository>(value),
    );
  }
}

String _$calendarRepositoryHash() =>
    r'd401b6362430334443edec78261d376be703d6f2';

@ProviderFor(workoutSessions)
final workoutSessionsProvider = WorkoutSessionsFamily._();

final class WorkoutSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutSessionEntity>>,
          List<WorkoutSessionEntity>,
          FutureOr<List<WorkoutSessionEntity>>
        >
    with
        $FutureModifier<List<WorkoutSessionEntity>>,
        $FutureProvider<List<WorkoutSessionEntity>> {
  WorkoutSessionsProvider._({
    required WorkoutSessionsFamily super.from,
    required (String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'workoutSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionsHash();

  @override
  String toString() {
    return r'workoutSessionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutSessionEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutSessionEntity>> create(Ref ref) {
    final argument = this.argument as (String, int, int);
    return workoutSessions(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSessionsHash() => r'3e85979ebab195c2c3f49b0aa1de7e2b75201a90';

final class WorkoutSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<WorkoutSessionEntity>>,
          (String, int, int)
        > {
  WorkoutSessionsFamily._()
    : super(
        retry: null,
        name: r'workoutSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutSessionsProvider call(String userId, int month, int year) =>
      WorkoutSessionsProvider._(argument: (userId, month, year), from: this);

  @override
  String toString() => r'workoutSessionsProvider';
}
