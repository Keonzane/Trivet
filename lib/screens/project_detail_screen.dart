import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/app_text_field.dart';
import '../widgets/caption.dart';
import '../widgets/choice_bar.dart';
import '../widgets/date_field.dart';
import '../widgets/detail_scaffold.dart';
import '../widgets/entry_modal.dart';
import '../widgets/pillar_button.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _projectStore = ProjectStore();
  final _logStore = WorkLogStore();
  late Project _project = widget.project;
  late final _notesController = TextEditingController(text: _project.notes);
  List<WorkLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final logs = await _logStore.load();
    if (!mounted) return;
    setState(() {
      _logs = logs.where((l) => l.projectId == _project.id).toList();
      _loading = false;
    });
  }

  void _update(Project Function(Project) change) {
    setState(() => _project = change(_project));
    _projectStore.put(_project);
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
    final totalHours = _logs.fold(0.0, (sum, l) => sum + l.hours);
    final lastLogged = _logs.isEmpty
        ? null
        : _logs.map((l) => l.date).reduce((a, b) => a.isAfter(b) ? a : b);

    return DetailScaffold(
      title: _project.title,
      loading: _loading,
      children: [
        Text(
          '${totalHours.toStringAsFixed(1)} h logged in total',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (lastLogged != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Caption('Last logged ${formatShortDate(lastLogged)}'),
        ],
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'Status',
          child: ChoiceBar<ProjectStatus>(
            values: ProjectStatus.values,
            selected: _project.status,
            labelOf: (s) => s.label,
            onSelected: (s) => _update((p) => p.copyWith(status: s)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'Due date',
          child: DateField(
            value: _project.dueDate,
            onChanged: (d) => _update((p) => p.withDueDate(d)),
            onClear: () => _update((p) => p.withDueDate(null)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'Notes',
          child: AppTextField(
            hint: 'Anything worth remembering about this project',
            controller: _notesController,
            maxLines: 4,
            onChanged: (t) => _update((p) => p.copyWith(notes: t.trim())),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PillarButton(
          pillar: Pillar.work,
          label: '+ Log hours',
          onPressed: _logMoreHours,
        ),
      ],
    );
  }
}
