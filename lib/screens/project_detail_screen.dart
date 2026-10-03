import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/date_field.dart';
import '../widgets/pillar_button.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen(
      {super.key, required this.project, required this.onUpdate});

  final Project project;

  final ValueChanged<Project> onUpdate;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _logStore = WorkLogStore();
  late Project _project;
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
    final all = await _logStore.load();
    setState(() {
      _allLogs = all;
      _loading = false;
    });
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
    setState(() => _project = _project.copyWith(status: status));
    widget.onUpdate(_project);
  }

  void _saveNotes() {
    setState(() =>
        _project = _project.copyWith(notes: _notesController.text.trim()));
    widget.onUpdate(_project);
  }

  Future<void> _logMoreHours() async {
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.work,
      initialProject: _project,
      onSaveWork: (project, log) async {
        _allLogs = [..._allLogs, log];
        await _logStore.save(_allLogs);
        if (mounted) setState(() {});
      },
    );
  }

  Widget _caption(ThemeData theme, String text) => Text(
        text,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.secondary),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastLogged = _lastLoggedDate;

    return Scaffold(
      appBar: AppBar(title: Text(_project.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _caption(theme, _project.subtitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_totalHours.toStringAsFixed(1)} h logged in total',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (lastLogged != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Last logged ${formatShortDate(lastLogged)}',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.secondary),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _caption(theme, 'STATUS'),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<ProjectStatus>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                            value: ProjectStatus.active, label: Text('Active')),
                        ButtonSegment(
                            value: ProjectStatus.paused, label: Text('Paused')),
                        ButtonSegment(
                            value: ProjectStatus.done, label: Text('Done')),
                      ],
                      selected: {_project.status},
                      onSelectionChanged: (s) => _setStatus(s.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _caption(theme, 'NOTES'),
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
