import 'package:flutter/material.dart';

import 'login_backdrop_painter.dart';

/// Abstract, people-free login backdrop drawn in code: drifting brand-colored
/// aurora, a dotted texture and a heartbeat line. Static when the OS asks
/// for reduced motion.
class LoginBackground extends StatefulWidget {
  const LoginBackground({super.key});

  @override
  State<LoginBackground> createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<LoginBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(painter: LoginBackdropPainter(_controller)),
      ),
    ),
  );
}
