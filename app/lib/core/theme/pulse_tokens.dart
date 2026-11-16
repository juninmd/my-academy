import 'package:flutter/animation.dart';

/// Paleta do sistema PULSE.
abstract final class PulseColors {
  // Escuro
  static const Color void_ = Color(0xFF0A0A0C);
  static const Color carbon = Color(0xFF141418);
  static const Color graphite = Color(0xFF26262E);
  static const Color steel = Color(0xFF33333D);
  static const Color chalk = Color(0xFFF4F4F5);
  static const Color mist = Color(0xFFA1A1AA);

  // Acentos
  /// Ação e progresso.
  static const Color volt = Color(0xFFC8FF2E);

  /// Volt escurecido para passar AA sobre fundos claros.
  static const Color voltDeep = Color(0xFF4D7C0F);

  /// Esforço, alertas e recordes pessoais.
  static const Color ember = Color(0xFFFF5A1F);
  static const Color emberDeep = Color(0xFFC2410C);

  // Claro
  static const Color paper = Color(0xFFF4F4F5);
  static const Color paperRaised = Color(0xFFFFFFFF);
  static const Color paperSunken = Color(0xFFE7E7EA);
  static const Color ink = Color(0xFF0A0A0C);
  static const Color inkMuted = Color(0xFF52525B);
}

/// Raios do sistema.
abstract final class PulseRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 28;
  static const double pill = 999;
}

/// Tokens de movimento.
abstract final class PulseMotion {
  /// Toque: encolhe e volta.
  static const Duration press = Duration(milliseconds: 120);

  /// Entrada de elementos (fade + deslocamento).
  static const Duration enter = Duration(milliseconds: 450);

  /// Atraso entre itens de uma lista.
  static const Duration stagger = Duration(milliseconds: 40);

  /// Preenchimento de anéis e barras.
  static const Duration fill = Duration(milliseconds: 900);

  /// Transição entre telas.
  static const Duration page = Duration(milliseconds: 420);

  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve spring = Cubic(0.2, 1.2, 0.3, 1);
}
