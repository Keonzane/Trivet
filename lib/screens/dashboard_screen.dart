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
import 'media_detail_screen.dart';

/// Screen 01 · Dashboard: the stat row, the nudge, and the "currently
/// enjoying" shelf, all computed live from the same five stores every
/// other screen reads. Not built yet: the triad chart (stretch, per the
/// proposal).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onSeeAllLeisure});

  /// Lets the app shell switch to the Leisure tab when "SEE ALL" is
  /// tapped. Null (e.g. in a test that mounts this screen alone) just
  /// hides the button rather than crashing on a missing callback.
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
    // All five stores load in parallel — none depends on another, and
    // this screen doesn't write anything until the person taps
    // + Log entry, so there's nothing to sequence.
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

    // Same "this week" filter every other screen uses, just applied
    // across all three pillars at once instead of one.
    final workHours = _workLogs
        .where((l) => week.contains(l.date))
        .fold(0.0, (sum, l) => sum + l.hours);

    final weekWorkouts = _workouts.where((w) => week.contains(w.date)).toList();

    final leisureMinutes = _leisureLogs
        .where((l) => week.contains(l.date))
        .fold(0, (sum, l) => sum + l.minutes);
    final leisureHours = leisureMinutes / 60;

    // Shelf caps at two rows per the mockup's own revision note (a third
    // row would push + Log entry off-screen on phone).
    final enjoying = _media
        .where((e) => e.status != MediaStatus.want)
        .take(2)
        .toList();

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
            StatCardRow(stats: [
              StatCardData(label: 'Hrs worked', value: workHours.toStringAsFixed(1)),
              StatCardData(label: 'Workouts', value: '${weekWorkouts.length}'),
              StatCardData(label: 'Leisure', value: '${leisureHours.toStringAsFixed(1)}h'),
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
    // The detail screen can log time on its own; reload so this screen's
    // hours-this-week reflects it.
    final logs = await _leisureLogStore.load();
    if (mounted) setState(() => _leisureLogs = logs);
  }

  String _weekRangeLabel(WeekRange week) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final start = week.start;
    final end = start.add(const Duration(days: 6));
    return '${days[start.weekday - 1]} ${start.day} – '
        '${days[end.weekday - 1]} ${end.day} ${months[end.month - 1]}';
  }

  /// Picks the thinnest pillar to name in the nudge. Work and Leisure are
  /// already both in hours, so they compare directly; Health uses a
  /// session count instead of hours (per the mockup's "WORKOUTS 3" stat),
  /// so it's handled as its own zero/non-zero check rather than folded
  /// into the same comparison — the proposal deliberately avoids inventing
  /// a shared unit across pillars, and this keeps that promise instead of
  /// quietly breaking it for the sake of one sentence of copy.
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
    final thinnest =
        workHours <= leisureHours ? 'Work' : 'Leisure';
    return '$thinnest is thin this week.';
  }

  /// This is the one place the unified sheet's pillar picker is opened
  /// truly unset and fully switchable — safe here specifically because
  /// this screen already loads all five stores, so whichever pillar gets
  /// chosen has somewhere real to save to.
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
