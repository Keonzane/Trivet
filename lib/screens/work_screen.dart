import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/pillar_button.dart';
import '../widgets/pillar_card.dart';
import '../widgets/work_entry_sheet.dart';

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
  ProjectStatus _filter = ProjectStatus.active;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await _projectStore.load();
    final logs = await _workLogStore.load();
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

  Future<void> _addHours(Project? project) async {
    await showWorkEntrySheet(
      context: context,
      projects: _projects,
      project: project,
      onSave: (project, log) async {
        setState(() {
          if (!_projects.any((p) => p.id == project.id)) {
            _projects = [..._projects, project];
          }
          _logs = [..._logs, log];
        });
        await _projectStore.save(_projects);
        await _workLogStore.save(_logs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _projects.where((p) => p.status == _filter).toList();
    final activeCount = _projects.where((p) => p.status == ProjectStatus.active).length;
    final weekTotal = _projects.fold<double>(0, (sum, p) => sum + _hoursThisWeek(p.id));
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$activeCount ACTIVE · ${weekTotal.toStringAsFixed(1)}H THIS WEEK',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Projects', style: theme.textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<ProjectStatus>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ProjectStatus.active, label: Text('Active')),
                  ButtonSegment(value: ProjectStatus.paused, label: Text('Paused')),
                  ButtonSegment(value: ProjectStatus.done, label: Text('Done')),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        message: _projects.isEmpty
                            ? 'No projects yet. Add one to start logging hours.'
                            : 'Nothing in ${_filter.name} yet.',
                        icon: Icons.work_outline,
                        actionLabel: _projects.isEmpty ? '+ Add project' : null,
                        onAction: _projects.isEmpty ? () => _addHours(null) : null,
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          final hours = _hoursThisWeek(p.id);
                          return PillarCard(
                            pillar: Pillar.work,
                            title: p.title,
                            subtitle: p.subtitle,
                            meta: '${hours.toStringAsFixed(1)} h',
                            onTap: () => _addHours(p),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              PillarButton(
                pillar: Pillar.work,
                label: '+ Add project',
                onPressed: () => _addHours(null),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
