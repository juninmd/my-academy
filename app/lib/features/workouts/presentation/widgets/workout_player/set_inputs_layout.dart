import 'package:flutter/material.dart';

/// Lays out a set row: `[reps, gap, weight, ...actions]`.
/// On narrow screens the actions wrap to a second line so the reps and
/// weight steppers keep enough width to show their values.
class SetInputsLayout extends StatelessWidget {
  const SetInputsLayout({required this.children, super.key});

  static const double breakpoint = 480;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(children: children);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: children.sublist(0, 3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: children.sublist(4),
            ),
          ],
        );
      },
    );
  }
}
