// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_page.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WelcomePageStore on _WelcomePageStoreBase, Store {
  late final _$workoutSummaryAtom =
      Atom(name: '_WelcomePageStoreBase.workoutSummary', context: context);

  @override
  WorkoutSummary? get workoutSummary {
    _$workoutSummaryAtom.reportRead();
    return super.workoutSummary;
  }

  @override
  set workoutSummary(WorkoutSummary? value) {
    _$workoutSummaryAtom.reportWrite(value, super.workoutSummary, () {
      super.workoutSummary = value;
    });
  }

  late final _$exerciseFrequencyAtom =
      Atom(name: '_WelcomePageStoreBase.exerciseFrequency', context: context);

  @override
  int get exerciseFrequency {
    _$exerciseFrequencyAtom.reportRead();
    return super.exerciseFrequency;
  }

  @override
  set exerciseFrequency(int value) {
    _$exerciseFrequencyAtom.reportWrite(value, super.exerciseFrequency, () {
      super.exerciseFrequency = value;
    });
  }

  late final _$lastWorkoutAtom =
      Atom(name: '_WelcomePageStoreBase.lastWorkout', context: context);

  @override
  String get lastWorkout {
    _$lastWorkoutAtom.reportRead();
    return super.lastWorkout;
  }

  @override
  set lastWorkout(String value) {
    _$lastWorkoutAtom.reportWrite(value, super.lastWorkout, () {
      super.lastWorkout = value;
    });
  }

  late final _$alreadyWorkoutAtom =
      Atom(name: '_WelcomePageStoreBase.alreadyWorkout', context: context);

  @override
  bool get alreadyWorkout {
    _$alreadyWorkoutAtom.reportRead();
    return super.alreadyWorkout;
  }

  @override
  set alreadyWorkout(bool value) {
    _$alreadyWorkoutAtom.reportWrite(value, super.alreadyWorkout, () {
      super.alreadyWorkout = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_WelcomePageStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$loadValuesAsyncAction =
      AsyncAction('_WelcomePageStoreBase.loadValues', context: context);

  @override
  Future<void> loadValues() {
    return _$loadValuesAsyncAction.run(() => super.loadValues());
  }

  @override
  String toString() {
    return '''
workoutSummary: ${workoutSummary},
exerciseFrequency: ${exerciseFrequency},
lastWorkout: ${lastWorkout},
alreadyWorkout: ${alreadyWorkout},
isLoading: ${isLoading}
    ''';
  }
}
