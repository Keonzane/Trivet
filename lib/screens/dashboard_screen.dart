import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';
import '../theme.dart';
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

    final weekWorkouts = _workouts.where((w) => week.contains(w.date)).toList();
    final healthMinutes =
        weekWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
    final healthHours = healthMinutes / 60;

    final leisureMinutes = _leisureLogs
        .where((l) => week.contains(l.date))
        .fold(0, (sum, l) => sum + l.minutes);
    final leisureHours = leisureMinutes / 60;

    final enjoying =
        _media.where((e) => e.status != MediaStatus.want).take(2).toList();

    final nudge = _nudgeFor(
      workHours: workHours,
      workoutCount: weekWorkouts.length,
      leisureHours: leisureHours,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              _weekRangeLabel(week),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('This week', style: theme.textTheme.headlineLarge),
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
                      child: _AxisLabel('WORK', theme),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 0,
                      child: _AxisLabel('LEISURE', theme),
                    ),
                    Positioned(
                      bottom: 14,
                      right: 0,
                      child: _AxisLabel('HEALTH', theme),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            StatCardRow(stats: [
              StatCardData(
                  label: 'Hrs worked', value: workHours.toStringAsFixed(1)),
              StatCardData(label: 'Workouts', value: '${weekWorkouts.length}'),
              StatCardData(
                  label: 'Leisure',
                  value: '${leisureHours.toStringAsFixed(1)}h'),
            ]),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(nudge, style: theme.textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (enjoying.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CURRENTLY ENJOYING',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.secondary),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAllLeisure,
                    child: const Text('SEE ALL'),
                  ),
                ],
              ),
              for (final e in enjoying) ...[
                MediaCard(
                  entry: e,
                  rating: e.rating,
                  progress: e.rating == null
                      ? '${_hoursThisWeek(e.id, week).toStringAsFixed(1)} h'
                      : null,
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

  double _hoursThisWeek(String mediaId, WeekRange week) {
    final minutes = _leisureLogs
        .where((l) => l.mediaId == mediaId && week.contains(l.date))
        .fold(0, (sum, l) => sum + l.minutes);
    return minutes / 60;
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
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final start = week.start;
    final end = start.add(const Duration(days: 6));
    return '${days[start.weekday - 1]} ${start.day} – '
        '${days[end.weekday - 1]} ${end.day} ${months[end.month - 1]}';
  }

  String _nudgeFor({
    required double workHours,
    required int workoutCount,
    required double leisureHours,
  }) {
    if (workHours == 0 && workoutCount == 0 && leisureHours == 0) {
      return 'Nothing logged yet this week.';
    }
    if (workoutCount == 0) {
      return 'No workouts logged yet this week.';
    }
    final thinnest = workHours <= leisureHours ? 'Work' : 'Leisure';
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
      onSaveLeisure: (entry, log) async {
        if (!_media.any((e) => e.id == entry.id)) {
          _media = [..._media, entry];
          await _mediaStore.save(_media);
        }
        _leisureLogs = [..._leisureLogs, log];
        await _leisureLogStore.save(_leisureLogs);
        if (mounted) setState(() {});
      },
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text, this.theme);

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: theme.textTheme.labelSmall
          ?.copyWith(color: theme.colorScheme.secondary),
    );
  }
}
