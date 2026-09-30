import 'package:flutter/material.dart';

import '../theme.dart';

class StatCardData {
  final String label;
  final String value;

  const StatCardData({required this.label, required this.value});
}

class StatCardRow extends StatelessWidget {
  const StatCardRow({super.key, required this.stats});

  final List<StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              Expanded(child: _Stat(data: stats[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.data});

  final StatCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label.toUpperCase(),
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.secondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(data.value, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}
