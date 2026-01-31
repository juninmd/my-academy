import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CelebrationWidget extends StatelessWidget {
  const CelebrationWidget({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2.seconds),

          // Content Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.amber, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .shimmer(delay: 1000.ms, duration: 1000.ms),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Sensacional!'),
                ).animate().scale(delay: 800.ms),
              ],
            ),
          ),

          // Confetti Particles (Simulated with simple icons)
          ...List.generate(6, (index) {
            final align = [
              Alignment.topLeft, Alignment.topRight,
              Alignment.centerLeft, Alignment.centerRight,
              Alignment.bottomLeft, Alignment.bottomRight
            ][index];
            return Align(
              alignment: align,
              child: const Icon(Icons.star, color: Colors.amber, size: 24)
                  .animate()
                  .scale(duration: 400.ms, begin: const Offset(0, 0), end: const Offset(1, 1))
                  .fade(delay: 500.ms, duration: 500.ms, begin: 1, end: 0)
                  .move(
                    begin: const Offset(0, 0),
                    end: Offset(
                      (index % 2 == 0 ? -50 : 50).toDouble(),
                      (index < 2 ? -50 : (index > 3 ? 50 : 0)).toDouble()
                    ),
                    duration: 1.seconds,
                  ),
            );
          }),
        ],
      ),
    );
  }
}
