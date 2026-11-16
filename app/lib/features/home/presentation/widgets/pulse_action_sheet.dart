import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/pulse_tokens.dart';
import '../../../../core/widgets/pulse/pressable.dart';
import '../../../../core/widgets/pulse/pulse_entrance.dart';
import '../../../workouts/presentation/widgets/one_rep_max_calculator_dialog.dart';
import '../../../workouts/presentation/widgets/plate_calculator_dialog.dart';
import 'body_weight_dialog.dart';
import 'quick_note_dialog.dart';
import 'quick_timer_dialog.dart';

class PulseAction {
  const PulseAction(this.icon, this.label, this.run, {this.hero = false});
  final IconData icon;
  final String label;
  final void Function(BuildContext context) run;
  final bool hero;
}

void _dialog(BuildContext context, Widget child) =>
    showDialog<void>(context: context, builder: (_) => child);

/// Todas as ações rápidas do app, a um toque do botão Pulse.
final pulseActions = <PulseAction>[
  PulseAction(
    Icons.play_arrow_rounded,
    'Treinar',
    (c) => c.go('/workouts'),
    hero: true,
  ),
  PulseAction(
    Icons.flash_on,
    'Treino Rápido',
    (c) => c.push('/workouts/create'),
  ),
  PulseAction(
    Icons.timer_outlined,
    'Cronômetro',
    (c) => _dialog(c, const QuickTimerDialog()),
  ),
  PulseAction(
    Icons.fitness_center,
    'Calc. 1RM',
    (c) => _dialog(c, const OneRepMaxCalculatorDialog()),
  ),
  PulseAction(
    Icons.calculate_outlined,
    'Anilhas',
    (c) => _dialog(c, const PlateCalculatorDialog(targetWeight: 0)),
  ),
  PulseAction(
    Icons.monitor_weight_outlined,
    'Peso',
    (c) => _dialog(c, const BodyWeightDialog()),
  ),
  PulseAction(
    Icons.edit_note,
    'Diário',
    (c) => _dialog(c, const QuickNoteDialog()),
  ),
  PulseAction(Icons.calendar_month, 'Calendário', (c) => c.go('/calendar')),
  PulseAction(Icons.history, 'Histórico', (c) => c.push('/history')),
];

Future<void> showPulseActionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => PulseActionSheet(host: context),
  );
}

class PulseActionSheet extends StatelessWidget {
  const PulseActionSheet({required this.host, super.key});

  /// Contexto de quem abriu a folha; continua montado depois do pop.
  final BuildContext host;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('O que vamos fazer?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              for (var i = 0; i < pulseActions.length; i++)
                _ActionTile(action: pulseActions[i], host: host).pulseIn(i),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.host});
  final PulseAction action;
  final BuildContext host;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = action.hero ? scheme.primary : scheme.surfaceContainerHigh;
    final fg = action.hero ? scheme.onPrimary : scheme.onSurface;
    return Pressable(
      onTap: () {
        Navigator.of(context).pop();
        action.run(host);
      },
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(PulseRadii.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: fg, size: 28),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
