import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/date_field.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_header.dart';
import '../widgets/workout_row.dart';

class AllWorkoutsScreen extends StatefulWidget {
  const AllWorkoutsScreen({super.key});

  @override
  State<AllWorkoutsScreen> createState() => _AllWorkoutsScreenState();
}

class _AllWorkoutsScreenState extends State<AllWorkoutsScreen> {
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

  Future<void> _replace(Workout w) async {
    setState(() {
      _workouts = [
        for (final x in _workouts)
          if (x.id == w.id) w else x,
      ];
    });
    await _store.save(_workouts);
  }

  Future<void> _delete(Workout w) async {
    setState(() => _workouts = _workouts.where((x) => x.id != w.id).toList());
    await _store.save(_workouts);
  }

  Future<void> _edit(Workout w) async {
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.health,
      initialWorkout: w,
      onSaveHealth: _replace,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [..._workouts]..sort((a, b) => b.date.compareTo(a.date));

    final groups = <DateTime, List<Workout>>{};
    for (final w in sorted) {
      final day = DateTime(w.date.year, w.date.month, w.date.day);
      groups.putIfAbsent(day, () => []).add(w);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All workouts'),
        actions: const [ThemeToggleButton()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : sorted.isEmpty
              ? const EmptyState(
                  message: 'No workouts logged yet.',
                  icon: Icons.favorite_outline,
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Text(
                      '${sorted.where((w) => w.done).length} OF ${sorted.length} DONE',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.secondary),
                    ),
                    for (final entry in groups.entries) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        formatShortDate(entry.key).toUpperCase(),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.secondary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final w in entry.value) ...[
                        DismissibleRow(
                          itemKey: ValueKey(w.id),
                          title: w.label,
                          confirmMessage: 'This removes this logged session.',
                          onDelete: () => _delete(w),
                          child: WorkoutRow(
                            workout: w,
                            subtitle:
                                'Gym · ${TimeOfDay.fromDateTime(w.date).format(context)}',
                            onToggleDone: () =>
                                _replace(w.copyWith(done: !w.done)),
                            onTap: () => _edit(w),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ],
                ),
    );
  }
}
