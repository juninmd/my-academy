import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/suggestion_entity.dart';
import 'muscle_overview_provider.dart';

/// Next target for one exercise, or null when there is no history or no user.
final suggestionProvider = FutureProvider.family<SuggestionEntity?, int>((
  ref,
  exerciseId,
) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;
  final result = await ref
      .watch(progressRepositoryProvider)
      .getSuggestion(user.id, exerciseId);
  return result.fold((failure) => throw Exception(failure.message), (s) => s);
});
