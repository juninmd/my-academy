import '../../domain/entities/muscle_overview_entity.dart';

/// Maps the response of `GET /progress/muscles`.
class MuscleOverviewDto {
  const MuscleOverviewDto._();

  static MuscleOverviewEntity fromJson(Map<String, dynamic> json) {
    final muscles = (json['muscles'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(_muscleOf)
        .toList();
    final balance = (json['balance'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(_pairOf)
        .toList();
    return MuscleOverviewEntity(muscles: muscles, balance: balance);
  }

  static MuscleProgressEntity _muscleOf(Map<String, dynamic> json) {
    return MuscleProgressEntity(
      muscle: json['muscle'] as String,
      weightedSets: (json['weightedSets'] as num).toDouble(),
      lastTrained: json['lastTrained'] == null
          ? null
          : DateTime.parse(json['lastTrained'] as String),
      state: _stateOf(json['state'] as String),
    );
  }

  static BalancePairEntity _pairOf(Map<String, dynamic> json) {
    return BalancePairEntity(
      key: json['key'] as String,
      label: json['label'] as String,
      left: (json['left'] as num).toDouble(),
      right: (json['right'] as num).toDouble(),
      ratio: (json['ratio'] as num?)?.toDouble(),
      status: _balanceOf(json['status'] as String),
    );
  }

  static MuscleState _stateOf(String value) {
    return switch (value) {
      'recovering' => MuscleState.recovering,
      'recovered' => MuscleState.recovered,
      _ => MuscleState.untrained,
    };
  }

  static BalanceStatus _balanceOf(String value) {
    return switch (value) {
      'left_low' => BalanceStatus.leftLow,
      'left_high' => BalanceStatus.leftHigh,
      'balanced' => BalanceStatus.balanced,
      'right_untrained' => BalanceStatus.rightUntrained,
      _ => BalanceStatus.noData,
    };
  }
}
