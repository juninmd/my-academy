import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/muscle_overview_entity.dart';
import '../../domain/repositories/progress_repository.dart';

// Written by hand, like the other providers, so build_runner is not needed.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(ref.watch(apiClientProvider));
});

/// Muscle volume, recovery and balance for the signed-in user. Empty when signed out.
final muscleOverviewProvider = FutureProvider.autoDispose<MuscleOverviewEntity>(
  (ref) async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      return const MuscleOverviewEntity(muscles: [], balance: []);
    }
    final result = await ref
        .watch(progressRepositoryProvider)
        .getMuscleOverview(user.id);
    return result.fold((failure) => throw Exception(failure.message), (o) => o);
  },
);
