import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/pulse_tokens.dart';

/// Anel de progresso que enche com animação sempre que [value] muda.
class PulseRing extends StatelessWidget {
  const PulseRing({
    required this.value,
    this.size = 84,
    this.stroke = 8,
    this.color,
    this.trackColor,
    this.child,
    this.duration = PulseMotion.fill,
    super.key,
  });

  /// Progresso entre 0 e 1 (valores fora do intervalo são limitados).
  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Color? trackColor;
  final Widget? child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: PulseMotion.emphasized,
        builder: (context, v, child) => CustomPaint(
          painter: PulseRingPainter(
            progress: v,
            stroke: stroke,
            color: color ?? scheme.primary,
            track: trackColor ?? scheme.surfaceContainerHighest,
          ),
          child: Center(child: child),
        ),
        child: child,
      ),
    );
  }
}

class PulseRingPainter extends CustomPainter {
  const PulseRingPainter({
    required this.progress,
    required this.stroke,
    required this.color,
    required this.track,
  });

  final double progress;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, 0, math.pi * 2, false, paint..color = track);
    if (progress <= 0) return;
    canvas.drawArc(
      arc,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(PulseRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
