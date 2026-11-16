import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/pulse_tokens.dart';

/// Traço de batimento (ECG), assinatura visual do PULSE. Desenha-se uma vez.
class PulseLine extends StatelessWidget {
  const PulseLine({
    required this.color,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 1400),
    super.key,
  });

  final Color color;
  final double strokeWidth;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration,
        curve: PulseMotion.emphasized,
        builder: (context, t, _) => CustomPaint(
          size: Size.infinite,
          painter: PulseLinePainter(t, color, strokeWidth),
        ),
      ),
    );
  }
}

class PulseLinePainter extends CustomPainter {
  const PulseLinePainter(this.progress, this.color, this.strokeWidth);

  final double progress;
  final Color color;
  final double strokeWidth;

  static const _points = [
    Offset(0, .5),
    Offset(.34, .5),
    Offset(.37, .5),
    Offset(.39, .1),
    Offset(.42, .9),
    Offset(.445, .25),
    Offset(.465, .66),
    Offset(.48, .5),
    Offset(1, .5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final p = Offset(_points[i].dx * size.width, _points[i].dy * size.height);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final PathMetric m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(PulseLinePainter old) =>
      old.progress != progress || old.color != color;
}
