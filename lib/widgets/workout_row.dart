import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../theme.dart';
import 'date_field.dart';
import 'pillar_card.dart';

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
    return PillarCard(
      pillar: Pillar.health,
      title: workout.label,
      subtitle: _subtitle(context),
      crossedOut: workout.done,
      leading: Checkbox(
        value: workout.done,
        activeColor: context.pillars.of(Pillar.health),
        onChanged: (_) => onToggleDone(),
      ),
      trailing: Text(
        '${workout.durationMinutes} min',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onTap: onTap,
    );
  }
}
