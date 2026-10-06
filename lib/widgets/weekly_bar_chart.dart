import 'package:flutter/material.dart';

import '../theme.dart';
import 'date_field.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.pillar,
  });

  final List<double> values;
  final Pillar pillar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.pillars.of(pillar);
    final restColor = theme.colorScheme.outlineVariant;
    final maxValue = values.fold<double>(0, (m, v) => v > m ? v : m);

    return SizedBox(
      height: 132,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final v in values) ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: maxValue == 0
                            ? 0.04
                            : (0.08 + 0.92 * (v / maxValue)).clamp(0.04, 1.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: v > 0 ? accent : restColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final day in weekdayNames)
                Expanded(
                  child: Text(
                    day[0],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.secondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
