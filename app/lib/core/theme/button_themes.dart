import 'package:flutter/material.dart';

import 'pulse_tokens.dart';

const _size = Size(64, 52);
const _padding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);
final _shape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(PulseRadii.md),
);

ElevatedButtonThemeData pulseElevatedButtons(
  ColorScheme scheme,
  TextStyle? label,
) => ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: scheme.primary,
    foregroundColor: scheme.onPrimary,
    elevation: 0,
    minimumSize: _size,
    padding: _padding,
    shape: _shape,
    textStyle: label,
  ),
);

FilledButtonThemeData pulseFilledButtons(TextStyle? label) =>
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: _size,
        padding: _padding,
        shape: _shape,
        textStyle: label,
      ),
    );

OutlinedButtonThemeData pulseOutlinedButtons(
  ColorScheme scheme,
  TextStyle? label,
) => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: scheme.onSurface,
    side: BorderSide(color: scheme.outline),
    minimumSize: _size,
    padding: _padding,
    shape: _shape,
    textStyle: label,
  ),
);

TextButtonThemeData pulseTextButtons(ColorScheme scheme, TextStyle? label) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: const Size(44, 44),
        textStyle: label,
      ),
    );
