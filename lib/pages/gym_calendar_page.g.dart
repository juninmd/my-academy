// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_calendar_page.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GymCalendarPageStore on _GymCalendarPageStoreBase, Store {
  Computed<List<WorkoutSession>>? _$selectedEventsComputed;

  @override
  List<WorkoutSession> get selectedEvents => (_$selectedEventsComputed ??=
          Computed<List<WorkoutSession>>(() => super.selectedEvents,
              name: '_GymCalendarPageStoreBase.selectedEvents'))
      .value;

  late final _$workoutSessionsAtom =
      Atom(name: '_GymCalendarPageStoreBase.workoutSessions', context: context);

  @override
  List<WorkoutSession> get workoutSessions {
    _$workoutSessionsAtom.reportRead();
    return super.workoutSessions;
  }

  @override
  set workoutSessions(List<WorkoutSession> value) {
    _$workoutSessionsAtom.reportWrite(value, super.workoutSessions, () {
      super.workoutSessions = value;
    });
  }

  late final _$selectedDayAtom =
      Atom(name: '_GymCalendarPageStoreBase.selectedDay', context: context);

  @override
  DateTime get selectedDay {
    _$selectedDayAtom.reportRead();
    return super.selectedDay;
  }

  @override
  set selectedDay(DateTime value) {
    _$selectedDayAtom.reportWrite(value, super.selectedDay, () {
      super.selectedDay = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_GymCalendarPageStoreBase.isLoading', context: context);

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
      AsyncAction('_GymCalendarPageStoreBase.loadValues', context: context);

  @override
  Future<void> loadValues() {
    return _$loadValuesAsyncAction.run(() => super.loadValues());
  }

  late final _$_GymCalendarPageStoreBaseActionController =
      ActionController(name: '_GymCalendarPageStoreBase', context: context);

  @override
  void setSelectedDay(DateTime day) {
    final _$actionInfo = _$_GymCalendarPageStoreBaseActionController
        .startAction(name: '_GymCalendarPageStoreBase.setSelectedDay');
    try {
      return super.setSelectedDay(day);
    } finally {
      _$_GymCalendarPageStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
workoutSessions: ${workoutSessions},
selectedDay: ${selectedDay},
isLoading: ${isLoading},
selectedEvents: ${selectedEvents}
    ''';
  }
}
