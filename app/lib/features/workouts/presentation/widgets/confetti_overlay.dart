import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ConfettiOverlay extends HookWidget {
  const ConfettiOverlay({
    required this.child,
    this.duration = const Duration(seconds: 3),
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration);
    final particles = useMemoized(() => List.generate(50, (_) => _Particle()));

    useEffect(() {
      controller.forward();
      return null;
    }, []);

    return Stack(
      children: [
        child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(
                  particles: particles,
                  progress: controller.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Particle {
  _Particle() {
    final random = Random();
    x = random.nextDouble(); // 0..1 horizontal
    y = -random.nextDouble() * 0.5; // Start above screen
    size = random.nextDouble() * 8 + 4;
    color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    velocity = random.nextDouble() * 0.5 + 0.5; // Vertical speed
    angle = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
    horizontalDrift = (random.nextDouble() - 0.5) * 0.2;
  }

  late double x;
  late double y;
  late double size;
  late Color color;
  late double velocity;
  late double angle;
  late double rotationSpeed;
  late double horizontalDrift;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    for (final particle in particles) {
      final dy =
          (particle.y + (progress * particle.velocity * 2.5)) * size.height;
      final dx =
          (particle.x + (progress * particle.horizontalDrift)) * size.width;

      // Opacity fade out at the end
      final opacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()..color = particle.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(particle.angle + (progress * particle.rotationSpeed * 20));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6, // Rectangular confetti
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
