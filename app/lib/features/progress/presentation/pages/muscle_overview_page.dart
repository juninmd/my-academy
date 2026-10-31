import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/muscle_overview_provider.dart';
import '../widgets/muscle_overview_view.dart';

class MuscleOverviewPage extends ConsumerWidget {
  const MuscleOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(muscleOverviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Músculos'),
        actions: [
          IconButton(
            tooltip: 'Conselho do coach',
            icon: const Icon(Icons.psychology),
            onPressed: () => _showAdvice(context, ref),
          ),
        ],
      ),
      body: overview.when(
        data: (data) => MuscleOverviewView(overview: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Não foi possível carregar: $error')),
      ),
    );
  }

  Future<void> _showAdvice(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final result = await ref
        .read(progressRepositoryProvider)
        .getCoachAdvice(user.id);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conselho do coach'),
        content: SingleChildScrollView(
          child: Text(
            result.fold(
              (failure) => 'O coach não respondeu: ${failure.message}',
              (advice) => advice,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
