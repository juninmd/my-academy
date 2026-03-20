import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerNotifier extends ValueNotifier<int> {
  TimerNotifier() : super(0);

  Timer? _timer;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      value++;
    });
  }

  void stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
