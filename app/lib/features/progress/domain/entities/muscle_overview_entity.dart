enum MuscleState { untrained, recovering, recovered }

enum BalanceStatus { noData, rightUntrained, leftLow, leftHigh, balanced }

class MuscleProgressEntity {
  const MuscleProgressEntity({
    required this.muscle,
    required this.weightedSets,
    required this.lastTrained,
    required this.state,
  });

  final String muscle;
  final double weightedSets;
  final DateTime? lastTrained;
  final MuscleState state;
}

class BalancePairEntity {
  const BalancePairEntity({
    required this.key,
    required this.label,
    required this.left,
    required this.right,
    required this.ratio,
    required this.status,
  });

  final String key;
  final String label;
  final double left;
  final double right;
  final double? ratio;
  final BalanceStatus status;
}

class MuscleOverviewEntity {
  const MuscleOverviewEntity({required this.muscles, required this.balance});

  final List<MuscleProgressEntity> muscles;
  final List<BalancePairEntity> balance;
}
