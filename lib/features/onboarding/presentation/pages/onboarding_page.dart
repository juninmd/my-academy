import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';
import '../../../profile/presentation/providers/settings_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _GoalPage(onNext: _nextPage),
                  _ExperiencePage(onNext: _nextPage),
                  _CommitmentPage(onFinish: _finishOnboarding),
                ],
              ),
            ),
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/home');
    }
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo ao MyAcademy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Seu assistente de treino pessoal. Vamos configurar seu perfil para começar.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Começar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalPage extends ConsumerWidget {
  final VoidCallback onNext;

  const _GoalPage({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: SettingsProvider needs to be updated to support 'goal'
    // For now, we will simulate the selection or store in a local state if provider isn't ready
    // But since the plan says "Update Profile/Settings", we assume we will add it later.
    // For now, let's just use local selection visually.

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Qual é seu objetivo?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _SelectionCard(
            title: 'Hipertrofia',
            subtitle: 'Ganhar massa muscular',
            icon: Icons.monitor_weight_outlined,
            onTap: () {
              ref.read(settingsProvider.notifier).setGoal('Hipertrofia');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Força',
            subtitle: 'Aumentar carga máxima',
            icon: Icons.fitness_center,
            onTap: () {
              ref.read(settingsProvider.notifier).setGoal('Força');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Resistência',
            subtitle: 'Melhorar condicionamento',
            icon: Icons.timer_outlined,
            onTap: () {
              ref.read(settingsProvider.notifier).setGoal('Resistência');
              onNext();
            },
          ),
        ],
      ),
    );
  }
}

class _ExperiencePage extends ConsumerWidget {
  final VoidCallback onNext;

  const _ExperiencePage({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Qual seu nível de experiência?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _SelectionCard(
            title: 'Iniciante',
            subtitle: 'Menos de 6 meses de treino',
            icon: Icons.person_outline,
            onTap: () {
              ref.read(settingsProvider.notifier).setExperienceLevel('Iniciante');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Intermediário',
            subtitle: '6 meses a 2 anos',
            icon: Icons.person,
            onTap: () {
              ref.read(settingsProvider.notifier).setExperienceLevel('Intermediário');
              onNext();
            },
          ),
          const SizedBox(height: 16),
          _SelectionCard(
            title: 'Avançado',
            subtitle: 'Mais de 2 anos de treino sério',
            icon: Icons.emoji_events_outlined,
            onTap: () {
              ref.read(settingsProvider.notifier).setExperienceLevel('Avançado');
              onNext();
            },
          ),
        ],
      ),
    );
  }
}

class _CommitmentPage extends ConsumerWidget {
  final VoidCallback onFinish;

  const _CommitmentPage({required this.onFinish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quantas vezes por semana você pretende treinar?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${settings.weeklyWorkoutGoal} dias',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Slider(
                    value: settings.weeklyWorkoutGoal.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: settings.weeklyWorkoutGoal.toString(),
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).setWeeklyGoal(value.round());
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onFinish,
              child: const Text('Concluir Configuração'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
