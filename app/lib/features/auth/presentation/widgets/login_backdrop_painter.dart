import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Paints the login aurora, dotted texture and heartbeat line for [progress].
class LoginBackdropPainter extends CustomPainter {
  LoginBackdropPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  static const _base = Color(0xFF0B0D12);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value * 2 * math.pi;
    canvas.drawRect(Offset.zero & size, Paint()..color = _base);

    _orb(canvas, size, const Offset(0.2, 0.15), t, AppTheme.primaryColor, 0.55);
    _orb(
      canvas,
      size,
      const Offset(0.85, 0.45),
      t + 2,
      AppTheme.secondaryColor,
      0.28,
    );
    _orb(
      canvas,
      size,
      const Offset(0.3, 0.9),
      t + 4,
      AppTheme.primaryVariant,
      0.45,
    );

    _dots(canvas, size);
    _pulse(canvas, size, progress.value);
  }

  void _orb(Canvas c, Size s, Offset anchor, double t, Color color, double a) {
    final r = s.longestSide * 0.55;
    final center = Offset(
      s.width * anchor.dx + math.cos(t) * s.width * 0.06,
      s.height * anchor.dy + math.sin(t) * s.height * 0.05,
    );
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: a), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  void _dots(Canvas c, Size s) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const gap = 28.0;
    for (var y = gap / 2; y < s.height; y += gap) {
      for (var x = gap / 2; x < s.width; x += gap) {
        c.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  void _pulse(Canvas c, Size s, double phase) {
    final y = s.height * 0.8;
    final path = Path()..moveTo(0, y);
    const beat = 220.0;
    for (var x = 0.0; x < s.width; x += beat) {
      path
        ..lineTo(x + beat * 0.40, y)
        ..lineTo(x + beat * 0.46, y - 18)
        ..lineTo(x + beat * 0.52, y + 26)
        ..lineTo(x + beat * 0.58, y - 52)
        ..lineTo(x + beat * 0.64, y + 10)
        ..lineTo(x + beat * 0.70, y)
        ..lineTo(x + beat, y);
    }
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppTheme.secondaryColor.withValues(alpha: 0.12),
    );

    // A bright segment travels along the line.
    final head = phase * (s.width + 240) - 120;
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = LinearGradient(
          colors: [
            AppTheme.secondaryColor.withValues(alpha: 0),
            AppTheme.secondaryColor.withValues(alpha: 0.8),
            AppTheme.secondaryColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(head - 120, y - 60, 240, 120)),
    );
  }

  @override
  bool shouldRepaint(LoginBackdropPainter old) => old.progress != progress;
}
