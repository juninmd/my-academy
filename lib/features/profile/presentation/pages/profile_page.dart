import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/body_composition_dialog.dart';
import '../widgets/consistency_heatmap.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authNotifierProvider);
    final user = userState.value;
    final settings = ref.watch(settingsProvider);
    final isEditing = useState(false);

    final nameController = useTextEditingController(text: user?.name ?? '');
    final emailController = useTextEditingController(text: user?.email ?? '');

    // For updates when user changes
    useEffect(() {
      nameController.text = user?.name ?? '';
      emailController.text = user?.email ?? '';
      return null;
    }, [user]);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Extract name logic to avoid complex expressions in widget tree
    final userName = user.name;
    final displayName = (userName != null && userName.isNotEmpty) ? userName[0].toUpperCase() : '?';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Estatísticas', icon: Icon(Icons.bar_chart)),
              Tab(text: 'Configurações', icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: STATISTICS
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage:
                              user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                  : null,
                          child:
                              user.photoUrl == null
                                  ? Text(
                                    displayName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  )
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name ?? 'Atleta',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Summary
                  ref.watch(allExerciseLogsProvider).when(
                    data: (logs) {
                      // Calculate Stats
                      final uniqueDays = logs
                          .map(
                            (l) => DateTime(
                              l.date.year,
                              l.date.month,
                              l.date.day,
                            ),
                          )
                          .toSet();
                      final totalWorkouts = uniqueDays.length;

                      double totalVolume = 0;
                      for (final log in logs) {
                        for (final set in log.sets) {
                          totalVolume += set.weight * set.reps;
                        }
                      }
                      final volumeDisplay =
                          totalVolume > 1000
                              ? '${(totalVolume / 1000).toStringAsFixed(1)} ton'
                              : '${totalVolume.toStringAsFixed(0)} kg';

                      // Streak Calculation
                      int streak = 0;
                      if (uniqueDays.isNotEmpty) {
                        final sortedDays = uniqueDays.toList()
                          ..sort((a, b) => b.compareTo(a));
                        final today = DateTime.now();
                        final todayDate = DateTime(
                          today.year,
                          today.month,
                          today.day,
                        );

                        // Check if trained today
                        var currentDate = todayDate;
                        if (!sortedDays.contains(currentDate)) {
                          currentDate = currentDate.subtract(
                            const Duration(days: 1),
                          );
                        }

                        while (sortedDays.contains(currentDate)) {
                          streak++;
                          currentDate = currentDate.subtract(
                            const Duration(days: 1),
                          );
                        }
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Treinos',
                                  value: totalWorkouts.toString(),
                                  icon: Icons.fitness_center,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  label: 'Volume Total',
                                  value: volumeDisplay,
                                  icon: Icons.monitor_weight,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Sequência',
                                  value: '$streak dias',
                                  icon: Icons.local_fire_department,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  label: 'Último Treino',
                                  value:
                                      logs.isNotEmpty
                                          ? DateFormat(
                                            'dd/MM',
                                          ).format(logs.first.date)
                                          : '-',
                                  icon: Icons.calendar_today,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                  ),

                  const SizedBox(height: 16),

                  // Consistency Heatmap
                  ref.watch(allExerciseLogsProvider).when(
                    data: (logs) => ConsistencyHeatmap(logs: logs),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),

                  const SizedBox(height: 16),

                  // Body Composition Card
                  Card(
                    child: InkWell(
                      onTap: () {
                         showDialog(
                           context: context,
                           builder: (context) => const BodyCompositionDialog(),
                         );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.accessibility_new, color: Colors.orange),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Composição Corporal',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Text(
                                    'Calcular % de gordura',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TAB 2: SETTINGS (Original Content Refactored)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Preferências de Treino',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.fitness_center),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Peso da Barra',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                '${settings.barWeight.toStringAsFixed(1)} kg',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Slider(
                            value: settings.barWeight,
                            min: 0,
                            max: 25,
                            divisions: 50,
                            label: settings.barWeight.toString(),
                            onChanged: (value) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setBarWeight(value);
                            },
                          ),
                          const Text(
                            'Usado na calculadora de anilhas.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              const Icon(Icons.monitor_weight_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Peso Corporal',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                '${settings.bodyWeight.toStringAsFixed(1)} kg',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Slider(
                            value: settings.bodyWeight,
                            min: 40,
                            max: 150,
                            divisions: 220,
                            label: settings.bodyWeight.toString(),
                            onChanged: (value) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setBodyWeight(value);
                            },
                          ),
                          const Text(
                            'Acompanhe sua evolução.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Inventário de Anilhas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selecione as anilhas disponíveis na sua academia:',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              25.0,
                              20.0,
                              15.0,
                              10.0,
                              5.0,
                              2.5,
                              1.25,
                              1.0,
                              0.5
                            ].map((plate) {
                              final isAvailable = settings.availablePlates.contains(plate);
                              return FilterChip(
                                label: Text('${plate}kg'),
                                selected: isAvailable,
                                onSelected: (_) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .togglePlateAvailability(plate);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Aparência',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.dark_mode_outlined),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Modo Escuro')),
                          Switch(
                            value: settings.themeMode == ThemeMode.dark,
                            onChanged: (val) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setThemeMode(
                                    val ? ThemeMode.dark : ThemeMode.light,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Account Actions
                  Text(
                    'Conta',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  if (isEditing.value) ...[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              isEditing.value = false;
                              nameController.text = user.name ?? '';
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              isEditing.value = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Perfil atualizado com sucesso! (Simulação)',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: () {
                        isEditing.value = true;
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar Nome'),
                    ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
