import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/muscle_overview_provider.dart';
import '../widgets/muscle_overview_view.dart';

class MuscleOverviewPage extends ConsumerWidget {
  const MuscleOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(muscleOverviewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Músculos')),
      body: overview.when(
        data: (data) => MuscleOverviewView(overview: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Não foi possível carregar: $error')),
      ),
    );
  }
}
