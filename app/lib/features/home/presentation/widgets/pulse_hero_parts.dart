import 'package:flutter/material.dart';

import '../../../../core/theme/pulse_tokens.dart';
import '../../../../core/widgets/pulse/pressable.dart';

class HeroTag extends StatelessWidget {
  const HeroTag(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PulseColors.ink,
        borderRadius: BorderRadius.circular(PulseRadii.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: PulseColors.volt, fontSize: 10),
      ),
    );
  }
}

class HeroActionPill extends StatelessWidget {
  const HeroActionPill({required this.label, required this.onTap,
    super.key,
  });
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 20, right: 6),
          decoration: BoxDecoration(
            color: PulseColors.ink,
            borderRadius: BorderRadius.circular(PulseRadii.pill),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PulseColors.volt,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: PulseColors.volt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: PulseColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
