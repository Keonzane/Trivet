import 'package:flutter/material.dart';

import '../theme.dart';

class PillarCard extends StatelessWidget {
  const PillarCard({
    super.key,
    required this.pillar,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.leading,
    this.crossedOut = false,
    required this.onTap,
  });

  final Pillar pillar;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final Widget? leading;
  final bool crossedOut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.pillars.of(pillar);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            if (leading != null) leading!,
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  leading == null ? AppSpacing.md : 0,
                  AppSpacing.sm + AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.sm + AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration:
                            crossedOut ? TextDecoration.lineThrough : null,
                        color: crossedOut ? theme.colorScheme.secondary : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.secondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }
}
