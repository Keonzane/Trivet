import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/caption.dart';
import '../widgets/date_field.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/pillar_button.dart';
import '../widgets/screen_header.dart';
import '../widgets/section.dart';
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
    if (!mounted) return;
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
    );
    await _load();
  }

  Future<void> _toggleDone(Workout w) async {
    await _store.put(w.toggledDone());
    await _load();
  }

  Future<void> _openAllWorkouts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AllWorkoutsScreen()),
    );
    await _load();
  }

  Future<void> _deleteWorkout(Workout w) async {
    setState(() => _workouts.removeWhere((x) => x.id == w.id));
    await _store.removeWhere((x) => x.id == w.id);
  }

  int get _streakDays {
    final days = _workouts
        .where((w) => w.done)
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
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

    final today = DateTime.now();
    final week = WeekRange.containing(today);
    final weekWorkouts = _workouts.where((w) => week.contains(w.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final doneThisWeek = weekWorkouts.where((w) => w.done).toList();
    final weekMinutes = _workouts.doneMinutesIn(week);
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

    Widget rowFor(Workout w, {String? dayLabel}) {
      return DismissibleRow(
        itemKey: ValueKey(w.id),
        title: w.label,
        confirmMessage: 'This removes this logged session.',
        onDelete: () => _deleteWorkout(w),
        child: WorkoutRow(
          workout: w,
          dayLabel: dayLabel,
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
            if (todays.isNotEmpty)
              Section(
                  title: 'TODAY',
                  children: [for (final w in todays) rowFor(w)]),
            Section(
              title: 'MINUTES PER DAY',
              trailing: Caption('$weekMinutes TOTAL'),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: WeeklyBarChart(
                        values: dailyMinutes, pillar: Pillar.health),
                  ),
                ),
              ],
            ),
            if (upcoming.isNotEmpty)
              Section(
                title: 'UPCOMING',
                children: [
                  for (final w in upcoming)
                    rowFor(w, dayLabel: formatShortDate(w.date)),
                ],
              ),
            if (earlier.isNotEmpty)
              Section(
                title: 'EARLIER THIS WEEK',
                children: [
                  for (final w in earlier)
                    rowFor(w, dayLabel: weekdayNames[w.date.weekday - 1]),
                ],
              ),
            if (weekWorkouts.isEmpty && upcoming.isEmpty)
              const EmptyState(
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
