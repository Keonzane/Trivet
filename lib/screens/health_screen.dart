import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/caption.dart';
import '../widgets/screen_header.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/date_field.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/pillar_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/workout_row.dart';
import 'all_workouts_screen.dart';

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
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.health,
      initialWorkout: existing,
      onSaveHealth: (w) async {
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

  Future<void> _toggleDone(Workout w) async {
    setState(() {
      _workouts = [
        for (final x in _workouts)
          if (x.id == w.id) x.copyWith(done: !x.done) else x,
      ];
    });
    await _store.save(_workouts);
  }

  Future<void> _openAllWorkouts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AllWorkoutsScreen()),
    );
    await _load();
  }

  Future<void> _deleteWorkout(Workout w) async {
    setState(() {
      _workouts = _workouts.where((x) => x.id != w.id).toList();
    });
    await _store.save(_workouts);
  }

  int get _streakDays {
    final days = _workouts
        .where((w) => w.done)
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor))
      cursor = cursor.subtract(const Duration(days: 1));
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

    final week = WeekRange.containing(DateTime.now());
    final weekWorkouts = _workouts.where((w) => week.contains(w.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final doneThisWeek = weekWorkouts.where((w) => w.done).toList();
    final weekMinutes =
        doneThisWeek.fold<int>(0, (sum, w) => sum + w.durationMinutes);

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final todays = weekWorkouts.where((w) => isSameDay(w.date, today)).toList();
    final earlier = weekWorkouts
        .where(
            (w) => !isSameDay(w.date, today) && w.date.isBefore(startOfToday))
        .toList();
    final upcoming = _workouts.where((w) => w.date.isAfter(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final dailyMinutes = List<double>.filled(7, 0);
    for (final w in doneThisWeek) {
      dailyMinutes[w.date.weekday - 1] += w.durationMinutes;
    }

    Widget rowFor(Workout w, String subtitle) {
      return DismissibleRow(
        itemKey: ValueKey(w.id),
        title: w.label,
        confirmMessage: 'This removes this logged session.',
        onDelete: () => _deleteWorkout(w),
        child: WorkoutRow(
          workout: w,
          subtitle: subtitle,
          onToggleDone: () => _toggleDone(w),
          onTap: () => _logWorkout(w),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            ScreenHeader(
              caption:
                  '${doneThisWeek.length} OF ${weekWorkouts.length} SESSIONS DONE',
              title: 'Workouts',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    pillar: Pillar.health,
                    label: 'Streak',
                    value: '$_streakDays',
                    unit: _streakDays == 1 ? 'day' : 'days',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    pillar: Pillar.health,
                    label: 'This week',
                    value: '$weekMinutes',
                    unit: 'min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (todays.isNotEmpty) ...[
              const Caption('TODAY'),
              const SizedBox(height: AppSpacing.sm),
              for (final w in todays) ...[
                rowFor(w,
                    'Gym · ${TimeOfDay.fromDateTime(w.date).format(context)}'),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Caption('MINUTES PER DAY'),
                Caption('$weekMinutes TOTAL'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child:
                    WeeklyBarChart(values: dailyMinutes, pillar: Pillar.health),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (upcoming.isNotEmpty) ...[
              const Caption('UPCOMING'),
              const SizedBox(height: AppSpacing.sm),
              for (final w in upcoming) ...[
                rowFor(w, 'Gym · ${formatShortDate(w.date)}'),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
            if (earlier.isNotEmpty) ...[
              const Caption('EARLIER THIS WEEK'),
              const SizedBox(height: AppSpacing.sm),
              for (final w in earlier) ...[
                rowFor(w,
                    'Gym · ${weekdayNames[w.date.weekday - 1]} ${TimeOfDay.fromDateTime(w.date).format(context)}'),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (weekWorkouts.isEmpty && upcoming.isEmpty)
              EmptyState(
                message: 'No workouts logged yet. Start with anything.',
                icon: Icons.favorite_outline,
              ),
            const SizedBox(height: AppSpacing.md),
            if (_workouts.isNotEmpty) ...[
              OutlinedButton(
                onPressed: _openAllWorkouts,
                child: Text('See all workouts (${_workouts.length})'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
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
}
