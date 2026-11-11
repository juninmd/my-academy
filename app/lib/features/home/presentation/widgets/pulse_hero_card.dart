import 'package:flutter/material.dart';

import '../../../../core/theme/pulse_tokens.dart';
import '../../../../core/widgets/pulse/pulse_line.dart';
import 'pulse_hero_parts.dart';

/// Cartão Volt de destaque: o treino que importa agora.
class PulseHeroCard extends StatelessWidget {
  const PulseHeroCard({
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.subtitle,
    this.tag,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final String? tag;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const ink = PulseColors.ink;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PulseRadii.xl),
      child: ColoredBox(
        color: PulseColors.volt,
        child: Stack(
          children: [
            const Positioned(
              right: -40,
              top: 0,
              width: 260,
              height: 120,
              child: Opacity(
                opacity: 0.16,
                child: PulseLine(color: ink, strokeWidth: 6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          eyebrow.toUpperCase(),
                          style: text.labelSmall?.copyWith(color: ink),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        HeroTag(tag!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.headlineMedium?.copyWith(
                      color: ink,
                      height: 1.05,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: text.bodyMedium?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  HeroActionPill(label: actionLabel, onTap: onAction),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
