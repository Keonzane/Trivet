import 'package:flutter/material.dart';

import '../theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.pillar,
    required this.label,
    required this.value,
    this.unit,
  });

  final Pillar pillar;
  final String label;
  final String value;

  final String? unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grey = theme.colorScheme.secondary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: context.pillars.of(pillar)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm + AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm + AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(color: grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text.rich(
                  TextSpan(
                    text: value,
                    style: theme.textTheme.headlineSmall,
                    children: [
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style:
                              theme.textTheme.labelSmall?.copyWith(color: grey),
                        ),
                    ],
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
