import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/health_entry_sheet.dart';
import '../widgets/pillar_button.dart';
import '../widgets/pillar_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _store = WorkoutStore();
  List<Workout> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final workouts = await _store.load();
    setState(() {
      _workouts = workouts;
      _loading = false;
    });
  }

  Future<void> _logWorkout(Workout? existing) async {
    await showHealthEntrySheet(
      context: context,
      workout: existing,
      onSave: (w) async {
        setState(() {
          _workouts = [
            for (final existingW in _workouts)
              if (existingW.id != w.id) existingW,
            w,
          ];
        });
        await _store.save(_workouts);
      },
    );
  }

  int get _streakDays {
    final days = _workouts.map((w) => DateTime(w.date.year, w.date.month, w.date.day)).toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    // A rest day today doesn't break a streak that continued through
    // yesterday; only count backward while consecutive days are logged.
    if (!days.contains(cursor)) cursor = cursor.subtract(const Duration(days: 1));
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final week = WeekRange.containing(DateTime.now());
    final weekWorkouts = _workouts.where((w) => week.contains(w.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final weekMinutes = weekWorkouts.fold<int>(0, (sum, w) => sum + w.durationMinutes);

    final today = DateTime.now();
    final isToday = (DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day;
    final todays = weekWorkouts.where((w) => isToday(w.date)).toList();
    final earlier = weekWorkouts.where((w) => !isToday(w.date)).toList();

    final dailyMinutes = List<double>.filled(7, 0);
    for (final w in weekWorkouts) {
      dailyMinutes[w.date.weekday - 1] += w.durationMinutes;
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${weekWorkouts.length} SESSIONS THIS WEEK',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Workouts', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.md),
            StatCardRow(stats: [
              StatCardData(label: 'Streak', value: '$_streakDays days'),
              StatCardData(label: 'This week', value: '$weekMinutes min'),
            ]),
            const SizedBox(height: AppSpacing.lg),
            if (todays.isNotEmpty) ...[
              Text('TODAY',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.secondary)),
              const SizedBox(height: AppSpacing.sm),
              for (final w in todays) ...[
                PillarCard(
                  pillar: Pillar.health,
                  title: w.label,
                  subtitle: 'Gym · ${TimeOfDay.fromDateTime(w.date).format(context)}',
                  meta: '${w.durationMinutes} min',
                  onTap: () => _logWorkout(w),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
            Text('MINUTES PER DAY',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.secondary)),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: WeeklyBarChart(values: dailyMinutes, pillar: Pillar.health),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (earlier.isNotEmpty) ...[
              Text('EARLIER THIS WEEK',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.secondary)),
              const SizedBox(height: AppSpacing.sm),
              for (final w in earlier) ...[
                PillarCard(
                  pillar: Pillar.health,
                  title: w.label,
                  subtitle: 'Gym · ${_weekday(w.date)} ${TimeOfDay.fromDateTime(w.date).format(context)}',
                  meta: '${w.durationMinutes} min',
                  onTap: () => _logWorkout(w),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (weekWorkouts.isEmpty)
              EmptyState(
                message: 'No workouts logged yet. Start with anything.',
                icon: Icons.favorite_outline,
              ),
            const SizedBox(height: AppSpacing.md),
            PillarButton(
              pillar: Pillar.health,
              label: '+ Log workout',
              onPressed: () => _logWorkout(null),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  String _weekday(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }
}
