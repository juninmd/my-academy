import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/user_role.dart';

/// Shell branch order; must match the StatefulShellRoute branches.
abstract final class Branch {
  static const home = 0;
  static const workouts = 1;
  static const calendar = 2;
  static const analytics = 3;
  static const profile = 4;
  static const students = 5;
  static const gym = 6;
}

class AppDestination {
  const AppDestination(this.label, this.icon, this.selectedIcon, this.branch);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int branch;
}

const _home = AppDestination(
  'Hoje',
  Icons.home_outlined,
  Icons.home_rounded,
  Branch.home,
);
const _workouts = AppDestination(
  'Treinos',
  Icons.fitness_center_outlined,
  Icons.fitness_center,
  Branch.workouts,
);
const _calendar = AppDestination(
  'Calendário',
  Icons.calendar_month_outlined,
  Icons.calendar_month,
  Branch.calendar,
);
const _analytics = AppDestination(
  'Progresso',
  Icons.insights_outlined,
  Icons.insights,
  Branch.analytics,
);
const _profile = AppDestination(
  'Você',
  Icons.person_outline,
  Icons.person,
  Branch.profile,
);
const _students = AppDestination(
  'Alunos',
  Icons.groups_outlined,
  Icons.groups,
  Branch.students,
);
const _gym = AppDestination(
  'Academia',
  Icons.store_mall_directory_outlined,
  Icons.store_mall_directory,
  Branch.gym,
);

List<AppDestination> destinationsFor(UserRole role) => switch (role) {
  UserRole.student => const [_home, _workouts, _calendar, _analytics, _profile],
  UserRole.personal => const [_home, _students, _workouts, _calendar, _profile],
  UserRole.owner => const [_gym, _workouts, _profile],
};

/// Abas da barra inferior no celular; o restante fica no botão Pulse.
List<AppDestination> barDestinationsFor(UserRole role) => switch (role) {
  UserRole.student => const [_home, _workouts, _analytics, _profile],
  UserRole.personal => const [_home, _students, _workouts, _profile],
  UserRole.owner => const [_gym, _workouts, _profile],
};

String homePathFor(UserRole role) => role == UserRole.owner ? '/gym' : '/home';
