import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/date_field.dart';
import '../widgets/media_card.dart';
import '../widgets/project_card.dart';
import '../widgets/screen_header.dart';
import '../widgets/section.dart';
import '../widgets/stat_card.dart';
import '../widgets/trivet_mark.dart';
import '../widgets/workout_row.dart';
import 'media_detail_screen.dart';
import 'project_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onSeeAllLeisure});

  final VoidCallback? onSeeAllLeisure;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _projectStore = ProjectStore();
  final _workLogStore = WorkLogStore();
  final _workoutStore = WorkoutStore();
  final _mediaStore = MediaStore();
  final _leisureLogStore = LeisureLogStore();

  List<Project> _projects = [];
  List<WorkLog> _workLogs = [];
  List<Workout> _workouts = [];
  List<MediaEntry> _media = [];
  List<LeisureLog> _leisureLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _projectStore.load(),
      _workLogStore.load(),
      _workoutStore.load(),
      _mediaStore.load(),
      _leisureLogStore.load(),
    ]);
    if (!mounted) return;
    setState(() {
      _projects = results[0] as List<Project>;
      _workLogs = results[1] as List<WorkLog>;
      _workouts = results[2] as List<Workout>;
      _media = results[3] as List<MediaEntry>;
      _leisureLogs = results[4] as List<LeisureLog>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final now = DateTime.now();
    final week = WeekRange.containing(now);

    final wantIds = {
      for (final e in _media)
        if (e.status == MediaStatus.want) e.id,
    };
    final hours = {
      Pillar.work: _workLogs.hoursIn(week),
      Pillar.health: _workouts.doneMinutesIn(week) / 60,
      Pillar.leisure:
          _leisureLogs.where((l) => !wantIds.contains(l.mediaId)).hoursIn(week),
    };

    final todaysWorkouts =
        _workouts.where((w) => isSameDay(w.date, now)).toList();
    final activeProjects =
        _projects.where((p) => p.status == ProjectStatus.active).toList();
    final enjoying = [
      ..._media.where((e) => e.status == MediaStatus.inProgress),
      ..._media.where((e) =>
          e.status == MediaStatus.done &&
          e.completedAt != null &&
          week.contains(e.completedAt!)),
    ];

    final thinnest =
        hours.entries.reduce((a, b) => b.value < a.value ? b : a).key;
    final nudge = hours.values.every((h) => h == 0)
        ? 'Nothing logged yet this week.'
        : '${thinnest.label} is thin this week.';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            ScreenHeader(
              caption: _weekRangeLabel(week),
              title: 'This week',
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TrivetMark(
                      work: hours[Pillar.work]!,
                      health: hours[Pillar.health]!,
                      leisure: hours[Pillar.leisure]!,
                    ),
                    const Positioned(top: 0, child: _AxisLabel(Pillar.work)),
                    const Positioned(
                        bottom: 14, left: 0, child: _AxisLabel(Pillar.leisure)),
                    const Positioned(
                        bottom: 14, right: 0, child: _AxisLabel(Pillar.health)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (final p in Pillar.values) ...[
                  if (p != Pillar.work) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatCard(
                      pillar: p,
                      label: p == Pillar.work ? 'Hrs worked' : p.label,
                      value: hours[p]!.toStringAsFixed(1),
                      unit: 'h',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: theme.colorScheme.onSurface),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(nudge, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (todaysWorkouts.isNotEmpty)
              Section(
                title: "TODAY'S WORKOUTS",
                children: [
                  for (final w in todaysWorkouts)
                    WorkoutRow(
                      workout: w,
                      onToggleDone: () => _toggleWorkout(w),
                      onTap: () => _logEntry(workout: w),
                    ),
                ],
              ),
            if (activeProjects.isNotEmpty)
              Section(
                title: 'ACTIVE WORK',
                children: [
                  for (final p in activeProjects)
                    ProjectCard(
                      project: p,
                      hoursThisWeek: _workLogs
                          .where((l) => l.projectId == p.id)
                          .hoursIn(week),
                      onTap: () => _open(ProjectDetailScreen(project: p)),
                    ),
                ],
              ),
            if (enjoying.isNotEmpty)
              Section(
                title: 'CURRENTLY ENJOYING',
                trailing: TextButton(
                  onPressed: widget.onSeeAllLeisure,
                  child: const Text('SEE ALL'),
                ),
                children: [
                  for (final e in enjoying)
                    MediaCard(
                        entry: e,
                        onTap: () => _open(MediaDetailScreen(entry: e))),
                ],
              ),
            FilledButton(
                onPressed: _logEntry, child: const Text('+ Log entry')),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleWorkout(Workout w) async {
    await _workoutStore.put(w.toggledDone());
    await _load();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    await _load();
  }

  Future<void> _logEntry({Workout? workout}) async {
    await showAddEntrySheet(
      context: context,
      initialPillar: workout == null ? null : Pillar.health,
      initialWorkout: workout,
    );
    await _load();
  }

  String _weekRangeLabel(WeekRange week) {
    final start = week.start;
    final end = start.add(const Duration(days: 6));
    return '${weekdayNames[start.weekday - 1]} ${start.day} – '
            '${weekdayNames[end.weekday - 1]} ${end.day} ${monthNames[end.month - 1]}'
        .toUpperCase();
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.pillar);

  final Pillar pillar;

  @override
  Widget build(BuildContext context) {
    return Text(
      pillar.label.toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: context.pillars.of(pillar)),
    );
  }
}
