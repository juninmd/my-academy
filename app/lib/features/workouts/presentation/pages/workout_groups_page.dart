import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/common_empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/workout_group_card.dart';

class WorkoutGroupsPage extends ConsumerWidget {
  const WorkoutGroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authNotifierProvider);
    final userId = userState.value?.id;

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final groupsAsync = ref.watch(workoutGroupsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Criar treino',
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/workouts/create');
            },
          ),
        ],
      ),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return CommonEmptyState(
              title: 'Nenhum treino encontrado',
              message: 'Crie sua primeira rotina de treinos para começar.',
              icon: Icons.fitness_center_outlined,
              actionLabel: 'Criar Treino',
              onAction: () => context.go('/workouts/create'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return WorkoutGroupCard(
                workoutGroup: group,
                onTap: () {
                  context.go('/workouts/${group.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
