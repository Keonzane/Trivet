import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/caption.dart';
import '../widgets/date_field.dart';
import '../widgets/pillar_button.dart';
import '../widgets/screen_header.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _projectStore = ProjectStore();
  final _logStore = WorkLogStore();
  late Project _project;
  List<Project> _allProjects = [];
  late final TextEditingController _notesController;
  List<WorkLog> _allLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _notesController = TextEditingController(text: _project.notes);
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final projects = await _projectStore.load();
    final logs = await _logStore.load();
    if (!mounted) return;
    setState(() {
      _allProjects = projects;
      _allLogs = logs;
      _loading = false;
    });
  }

  void _update(Project Function(Project) change) {
    setState(() => _project = change(_project));
    _allProjects = [
      for (final p in _allProjects)
        if (p.id == _project.id) _project else p,
    ];
    _projectStore.save(_allProjects);
  }

  List<WorkLog> get _projectLogs =>
      _allLogs.where((l) => l.projectId == _project.id).toList();

  double get _totalHours => _projectLogs.fold(0.0, (sum, l) => sum + l.hours);

  DateTime? get _lastLoggedDate {
    if (_projectLogs.isEmpty) return null;
    return _projectLogs
        .map((l) => l.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  void _setStatus(ProjectStatus status) {
    _update((p) => p.copyWith(status: status));
  }

  void _saveNotes() {
    _update((p) => p.copyWith(notes: _notesController.text.trim()));
  }

  Future<void> _logMoreHours() async {
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.work,
      initialProject: _project,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastLogged = _lastLoggedDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.title),
        actions: const [ThemeToggleButton()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Caption(_project.subtitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_totalHours.toStringAsFixed(1)} h logged in total',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (lastLogged != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Caption('Last logged ${formatShortDate(lastLogged)}'),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    const Caption('STATUS'),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<ProjectStatus>(
                      showSelectedIcon: false,
                      expandedInsets: EdgeInsets.zero,
                      segments: [
                        for (final s in ProjectStatus.values)
                          ButtonSegment(value: s, label: Text(s.label)),
                      ],
                      selected: {_project.status},
                      onSelectionChanged: (s) => _setStatus(s.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Caption('NOTES'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Anything worth remembering about this project',
                      ),
                      onEditingComplete: _saveNotes,
                      onTapOutside: (_) => _saveNotes(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PillarButton(
                      pillar: Pillar.work,
                      label: '+ Log hours',
                      onPressed: _logMoreHours,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
    );
  }
}
