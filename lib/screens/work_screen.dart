import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/date_field.dart';
import '../widgets/screen_header.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/pillar_button.dart';
import '../widgets/pillar_card.dart';
import '../widgets/sectioned_list.dart';
import 'project_detail_screen.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final _projectStore = ProjectStore();
  final _workLogStore = WorkLogStore();

  List<Project> _projects = [];
  List<WorkLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await _projectStore.load();
    final logs = await _workLogStore.load();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _logs = logs;
      _loading = false;
    });
  }

  double _hoursThisWeek(String projectId) {
    final week = WeekRange.containing(DateTime.now());
    return _logs
        .where((l) => l.projectId == projectId && week.contains(l.date))
        .fold(0.0, (sum, l) => sum + l.hours);
  }

  String _rowSubtitle(Project p) {
    final dates = _logs.where((l) => l.projectId == p.id).map((l) => l.date);
    if (dates.isEmpty) return p.subtitle;
    final last = dates.reduce((a, b) => a.isAfter(b) ? a : b);
    final today = DateTime.now();
    final daysAgo = DateTime(today.year, today.month, today.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    final when = daysAgo == 0
        ? 'today'
        : (daysAgo > 0 && daysAgo < 7)
            ? weekdayNames[last.weekday - 1]
            : '${last.day} ${monthNames[last.month - 1]}';
    return '${p.subtitle} · last logged $when';
  }

  Future<void> _addProject() async {
    await showAddEntrySheet(context: context, initialPillar: Pillar.work);
    await _load();
  }

  Future<void> _openDetail(Project p) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: p)),
    );
    await _load();
  }

  Future<void> _deleteProject(Project p) async {
    setState(() {
      _projects = _projects.where((x) => x.id != p.id).toList();
      _logs = _logs.where((l) => l.projectId != p.id).toList();
    });
    await _projectStore.save(_projects);
    await _workLogStore.save(_logs);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeCount =
        _projects.where((p) => p.status == ProjectStatus.active).length;
    final weekTotal =
        _projects.fold<double>(0, (sum, p) => sum + _hoursThisWeek(p.id));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                caption:
                    '$activeCount ACTIVE · ${weekTotal.toStringAsFixed(1)}H THIS WEEK',
                title: 'Projects',
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _projects.isEmpty
                    ? EmptyState(
                        message:
                            'No projects yet. Add one to start logging hours.',
                        icon: Icons.work_outline,
                        actionLabel: '+ Add project',
                        onAction: _addProject,
                      )
                    : SectionedList<ProjectStatus>(
                        sections: ProjectStatus.values,
                        initial: ProjectStatus.active,
                        labelOf: (s) => s.label,
                        itemsOf: (s) => [
                          for (final p in _projects.where((p) => p.status == s))
                            DismissibleRow(
                              itemKey: ValueKey(p.id),
                              title: p.title,
                              confirmMessage:
                                  'This also removes every logged hour for this project.',
                              onDelete: () => _deleteProject(p),
                              child: PillarCard(
                                pillar: Pillar.work,
                                title: p.title,
                                subtitle: _rowSubtitle(p),
                                trailing: Text(
                                  '${_hoursThisWeek(p.id).toStringAsFixed(1)} h',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                onTap: () => _openDetail(p),
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              PillarButton(
                pillar: Pillar.work,
                label: '+ Add project',
                onPressed: _addProject,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
