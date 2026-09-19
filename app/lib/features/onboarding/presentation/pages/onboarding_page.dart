import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/commitment_step.dart';
import '../widgets/role_step.dart';
import '../widgets/student_steps.dart';
import '../widgets/welcome_step.dart';

const _stepCount = 5;

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _savingRole = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      WelcomeStep(onNext: _nextPage),
                      RoleStep(onSelected: _selectRole, busy: _savingRole),
                      GoalStep(onNext: _nextPage),
                      ExperienceStep(onNext: _nextPage),
                      CommitmentStep(onFinish: _finishOnboarding),
                    ],
                  ),
                ),
                Semantics(
                  label: 'Passo ${_currentPage + 1} de $_stepCount',
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_stepCount, (index) {
                        final active = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(
                              alpha: active ? 1 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Future<void> _selectRole(UserRole role) async {
    setState(() => _savingRole = true);
    try {
      await ref.read(authNotifierProvider.notifier).updateRole(role.apiValue);
      if (!mounted) return;
      role == UserRole.student ? _nextPage() : await _finishOnboarding();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar seu perfil.')),
      );
    } finally {
      if (mounted) setState(() => _savingRole = false);
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) context.go('/home');
  }
}
