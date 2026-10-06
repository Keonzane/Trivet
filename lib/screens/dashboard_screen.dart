import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/caption.dart';
import '../widgets/date_field.dart';
import '../widgets/screen_header.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/media_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/trivet_mark.dart';
import 'media_detail_screen.dart';

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

    final enjoying = _media
        .where((e) => e.status == MediaStatus.inProgress)
        .take(2)
        .toList();

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

  Future<void> _openMediaDetail(MediaEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaDetailScreen(
          entry: entry,
          onUpdate: (updated) async {
            _media = [
              for (final e in _media)
                if (e.id == updated.id) updated else e,
            ];
            await _mediaStore.save(_media);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
    final logs = await _leisureLogStore.load();
    if (mounted) setState(() => _leisureLogs = logs);
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
    await showAddEntrySheet(
      context: context,
      initialPillar: null,
      onSaveWork: (project, log) async {
        if (!_projects.any((p) => p.id == project.id)) {
          _projects = [..._projects, project];
          await _projectStore.save(_projects);
        }
        _workLogs = [..._workLogs, log];
        await _workLogStore.save(_workLogs);
        if (mounted) setState(() {});
      },
      onSaveHealth: (w) async {
        _workouts = [..._workouts, w];
        await _workoutStore.save(_workouts);
        if (mounted) setState(() {});
      },
      onSaveLeisure: (entry) async {
        _media = [..._media, entry];
        await _mediaStore.save(_media);
        if (mounted) setState(() {});
      },
    );
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
