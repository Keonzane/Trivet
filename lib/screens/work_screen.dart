import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/pillar_button.dart';
import '../widgets/project_card.dart';
import '../widgets/screen_header.dart';
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
      _projects.removeWhere((x) => x.id == p.id);
      _logs.removeWhere((l) => l.projectId == p.id);
    });
    await _projectStore.removeWhere((x) => x.id == p.id);
    await _workLogStore.removeWhere((l) => l.projectId == p.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeCount =
        _projects.where((p) => p.status == ProjectStatus.active).length;
    final week = WeekRange.thisWeek();
    final weekTotal = _logs.hoursIn(week);

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
                              child: ProjectCard(
                                project: p,
                                hoursThisWeek: _logs
                                    .where((l) => l.projectId == p.id)
                                    .hoursIn(week),
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
