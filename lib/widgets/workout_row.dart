import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../theme.dart';
import 'caption.dart';
import 'date_field.dart';

class WorkoutRow extends StatelessWidget {
  const WorkoutRow({
    super.key,
    required this.workout,
    this.dayLabel,
    required this.onToggleDone,
    required this.onTap,
  });

  final Workout workout;
  final String? dayLabel;
  final VoidCallback onToggleDone;
  final VoidCallback onTap;

  String _subtitle(BuildContext context) {
    final completedAt = workout.completedAt;
    if (workout.done && completedAt != null) {
      final time = TimeOfDay.fromDateTime(completedAt).format(context);
      final day = isSameDay(completedAt, DateTime.now())
          ? ''
          : '${weekdayNames[completedAt.weekday - 1]} ';
      return 'Gym · Done $day$time';
    }
    if (workout.done) return 'Gym · Done';
    return dayLabel == null ? 'Gym' : 'Gym · $dayLabel';
  }

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
                          decoration:
                              workout.done ? TextDecoration.lineThrough : null,
                          color:
                              workout.done ? theme.colorScheme.secondary : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Caption(_subtitle(context)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text('${workout.durationMinutes} min',
                    style: theme.textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
