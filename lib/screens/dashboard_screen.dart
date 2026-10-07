import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/caption.dart';
import '../widgets/date_field.dart';
import '../widgets/media_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/project_card.dart';
import '../widgets/screen_header.dart';
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
    final week = WeekRange.containing(DateTime.now());

    final workHours = _workLogs
        .where((l) => week.contains(l.date))
        .fold(0.0, (sum, l) => sum + l.hours);

    final weekWorkouts =
        _workouts.where((w) => week.contains(w.date) && w.done).toList();
    final healthMinutes =
        weekWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
    final healthHours = healthMinutes / 60;

    final wantIds = _media
        .where((e) => e.status == MediaStatus.want)
        .map((e) => e.id)
        .toSet();
    final leisureMinutes = _leisureLogs
        .where((l) => week.contains(l.date) && !wantIds.contains(l.mediaId))
        .fold(0, (sum, l) => sum + l.minutes);
    final leisureHours = leisureMinutes / 60;

    final now = DateTime.now();
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

    final nudge = _nudgeFor(
      workHours: workHours,
      healthHours: healthHours,
      leisureHours: leisureHours,
    );

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
                        work: workHours,
                        health: healthHours,
                        leisure: leisureHours),
                    Positioned(
                      top: 0,
                      child: _AxisLabel('WORK', Pillar.work),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 0,
                      child: _AxisLabel('LEISURE', Pillar.leisure),
                    ),
                    Positioned(
                      bottom: 14,
                      right: 0,
                      child: _AxisLabel('HEALTH', Pillar.health),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    pillar: Pillar.work,
                    label: 'Hrs worked',
                    value: workHours.toStringAsFixed(1),
                    unit: 'h',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    pillar: Pillar.health,
                    label: 'Health',
                    value: healthHours.toStringAsFixed(1),
                    unit: 'h',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    pillar: Pillar.leisure,
                    label: 'Leisure',
                    value: leisureHours.toStringAsFixed(1),
                    unit: 'h',
                  ),
                ),
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
            if (todaysWorkouts.isNotEmpty) ...[
              const Caption("TODAY'S WORKOUTS"),
              const SizedBox(height: AppSpacing.sm),
              for (final w in todaysWorkouts) ...[
                WorkoutRow(
                  workout: w,
                  onToggleDone: () => _toggleWorkout(w),
                  onTap: () => _editWorkout(w),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
            if (activeProjects.isNotEmpty) ...[
              const Caption('ACTIVE WORK'),
              const SizedBox(height: AppSpacing.sm),
              for (final p in activeProjects) ...[
                ProjectCard(
                  project: p,
                  hoursThisWeek: _projectHours(p.id, week),
                  onTap: () => _openProject(p),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
            if (enjoying.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Caption('CURRENTLY ENJOYING'),
                  TextButton(
                    onPressed: widget.onSeeAllLeisure,
                    child: const Text('SEE ALL'),
                  ),
                ],
              ),
              for (final e in enjoying) ...[
                MediaCard(
                  entry: e,
                  onTap: () => _openMediaDetail(e),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
            PrimaryButton(
              label: '+ Log entry',
              onPressed: _openAddEntry,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  double _projectHours(String projectId, WeekRange week) => _workLogs
      .where((l) => l.projectId == projectId && week.contains(l.date))
      .fold(0.0, (sum, l) => sum + l.hours);

  Future<void> _toggleWorkout(Workout w) async {
    final workouts = await _workoutStore.toggleDone(w);
    if (mounted) setState(() => _workouts = workouts);
  }

  Future<void> _editWorkout(Workout w) async {
    await showAddEntrySheet(
        context: context, initialPillar: Pillar.health, initialWorkout: w);
    await _load();
  }

  Future<void> _openProject(Project p) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: p)),
    );
    await _load();
  }

  Future<void> _openMediaDetail(MediaEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MediaDetailScreen(entry: entry)),
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

  String _nudgeFor({
    required double workHours,
    required double healthHours,
    required double leisureHours,
  }) {
    if (workHours == 0 && healthHours == 0 && leisureHours == 0) {
      return 'Nothing logged yet this week.';
    }
    final hours = {
      'Work': workHours,
      'Health': healthHours,
      'Leisure': leisureHours,
    };
    final thinnest =
        hours.entries.reduce((a, b) => b.value < a.value ? b : a).key;
    return '$thinnest is thin this week.';
  }

  Future<void> _openAddEntry() async {
    await showAddEntrySheet(context: context);
    await _load();
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text, this.pillar);

  final String text;
  final Pillar pillar;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: context.pillars.of(pillar)),
    );
  }
}
