import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/work_log.dart';
import '../theme.dart';
import 'app_text_field.dart';
import 'duration_stepper.dart';
import 'entry_modal.dart';

const _newProjectId = '__new__';

Future<void> showWorkEntrySheet({
  required BuildContext context,
  required List<Project> projects,
  required Project? project,
  required void Function(Project project, WorkLog log) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _WorkEntrySheet(
      projects: projects,
      initialProject: project,
      onSave: onSave,
    ),
  );
}

class _WorkEntrySheet extends StatefulWidget {
  const _WorkEntrySheet({
    required this.projects,
    required this.initialProject,
    required this.onSave,
  });

  final List<Project> projects;
  final Project? initialProject;
  final void Function(Project project, WorkLog log) onSave;

  @override
  State<_WorkEntrySheet> createState() => _WorkEntrySheetState();
}

class _WorkEntrySheetState extends State<_WorkEntrySheet> {
  late String _selectedId;
  double _hours = 1.0;
  DateTime _date = DateTime.now();
  bool _showTitleError = false;
  late final TextEditingController _newTitleController;
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialProject?.id ??
        (widget.projects.isNotEmpty ? widget.projects.first.id : _newProjectId);
    _newTitleController = TextEditingController();
    _dateController = TextEditingController(text: _formatDate(_date));
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  bool get _isNew => _selectedId == _newProjectId;

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _save() {
    Project project;
    if (_isNew) {
      final title = _newTitleController.text.trim();
      if (title.isEmpty) {
        setState(() => _showTitleError = true);
        return;
      }
      project = Project(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        subtitle: 'Personal',
        status: ProjectStatus.active,
      );
    } else {
      project = widget.projects.firstWhere((p) => p.id == _selectedId);
    }
    widget.onSave(
      project,
      WorkLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        projectId: project.id,
        hours: _hours,
        date: _date,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return EntryModal(
      pillar: Pillar.work,
      title: 'Log hours',
      onCancel: () => Navigator.of(context).pop(),
      onSave: _save,
      fields: [
        LabelledField(
          label: 'Project',
          child: DropdownButtonFormField<String>(
            value: _selectedId,
            isExpanded: true,
            items: [
              for (final p in widget.projects)
                DropdownMenuItem(value: p.id, child: Text(p.title)),
              const DropdownMenuItem(
                value: _newProjectId,
                child: Text('+ New project'),
              ),
            ],
            onChanged: (id) => setState(() {
              _selectedId = id!;
              _showTitleError = false;
            }),
          ),
        ),
        if (_isNew)
          LabelledField(
            label: 'New project title',
            child: AppTextField(
              hint: 'e.g. Portfolio site',
              controller: _newTitleController,
              errorText: _showTitleError ? 'Enter a title' : null,
            ),
          ),
        LabelledField(
          label: 'Duration',
          child: DurationStepper(
            value: _hours,
            step: 0.5,
            unit: 'h',
            onChanged: (v) => setState(() => _hours = v.toDouble()),
          ),
        ),
        LabelledField(
          label: 'Date',
          child: AppTextField(
            hint: 'Date',
            controller: _dateController,
            onTap: _pickDate,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
        ),
      ],
    );
  }
}
