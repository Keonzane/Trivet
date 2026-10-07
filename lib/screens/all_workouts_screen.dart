import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/caption.dart';
import '../widgets/date_field.dart';
import '../widgets/detail_scaffold.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/section.dart';
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
    if (!mounted) return;
    setState(() {
      _workouts = workouts;
      _loading = false;
    });
  }

  Future<void> _toggleDone(Workout w) async {
    await _store.put(w.toggledDone());
    await _load();
  }

  Future<void> _delete(Workout w) async {
    setState(() => _workouts.removeWhere((x) => x.id == w.id));
    await _store.removeWhere((x) => x.id == w.id);
  }

  Future<void> _edit(Workout w) async {
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.health,
      initialWorkout: w,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._workouts]..sort((a, b) => b.date.compareTo(a.date));

    final groups = <DateTime, List<Workout>>{};
    for (final w in sorted) {
      final day = DateTime(w.date.year, w.date.month, w.date.day);
      groups.putIfAbsent(day, () => []).add(w);
    }

    return DetailScaffold(
      title: 'All workouts',
      loading: _loading,
      children: [
        if (sorted.isEmpty)
          const EmptyState(
              message: 'No workouts logged yet.', icon: Icons.favorite_outline)
        else ...[
          Caption(
              '${sorted.where((w) => w.done).length} OF ${sorted.length} DONE'),
          const SizedBox(height: AppSpacing.lg),
          for (final entry in groups.entries)
            Section(
              title: formatShortDate(entry.key).toUpperCase(),
              children: [
                for (final w in entry.value)
                  DismissibleRow(
                    itemKey: ValueKey(w.id),
                    title: w.label,
                    confirmMessage: 'This removes this logged session.',
                    onDelete: () => _delete(w),
                    child: WorkoutRow(
                      workout: w,
                      onToggleDone: () => _toggleDone(w),
                      onTap: () => _edit(w),
                    ),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}
