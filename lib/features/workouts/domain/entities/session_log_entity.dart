enum SetType {
  normal,
  warmup,
  dropset,
  failure
}

class SetLogState {
  SetLogState({
    required this.actualReps,
    required this.actualWeight,
    this.rpe,
    this.isCompleted = false,
    this.type = SetType.normal,
  });

  int actualReps;
  int actualWeight;
  int? rpe;
  bool isCompleted;
  SetType type;
}

class ExerciseSessionLog {
  ExerciseSessionLog({
    required this.exerciseId,
    required this.setLogs,
    this.notes,
    this.exerciseName,
  });

  final int exerciseId;
  final String? exerciseName;
  final Map<int, SetLogState> setLogs;
  final String? notes;
}
