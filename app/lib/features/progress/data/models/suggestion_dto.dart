import '../../domain/entities/suggestion_entity.dart';

/// Maps `GET /progress/exercises/:id/suggestion`; `suggestion` is null without history.
class SuggestionDto {
  const SuggestionDto._();

  static SuggestionEntity? fromResponse(Map<String, dynamic> json) {
    final suggestion = json['suggestion'];
    if (suggestion == null) return null;
    final map = suggestion as Map<String, dynamic>;
    return SuggestionEntity(
      weight: (map['weight'] as num).toDouble(),
      reps: (map['reps'] as num).toInt(),
      sets: (map['sets'] as num).toInt(),
      deload: map['deload'] as bool,
      reason: map['reason'] as String,
    );
  }
}
