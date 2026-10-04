import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../theme.dart';

class WorkoutRow extends StatelessWidget {
  const WorkoutRow({
    super.key,
    required this.workout,
    required this.subtitle,
    required this.onToggleDone,
    required this.onTap,
  });

  final Workout workout;
  final String subtitle;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.pillars.of(Pillar.health);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Checkbox(
                value: workout.done,
                activeColor: accent,
                onChanged: (_) => onToggleDone(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: workout.done ? TextDecoration.lineThrough : null,
                          color: workout.done ? theme.colorScheme.secondary : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text('${workout.durationMinutes} min', style: theme.textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
