import 'package:flutter/widgets.dart';

import '../../theme/pulse_tokens.dart';

/// Entrada padrão do PULSE: fade + subida, escalonada por [index].
///
/// O atraso vive dentro da própria curva (sem timers), então testes com
/// `pumpAndSettle` e telas descartadas cedo nunca deixam nada pendente.
extension PulseEntrance on Widget {
  Widget pulseIn([int index = 0]) => PulseIn(index: index, child: this);
}

class PulseIn extends StatelessWidget {
  const PulseIn({required this.child, this.index = 0, super.key});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final delay = PulseMotion.stagger * index;
    final total = delay + PulseMotion.enter;
    final start = delay.inMicroseconds / total.inMicroseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: PulseMotion.emphasized),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
