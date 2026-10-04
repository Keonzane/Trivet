import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';
import '../theme.dart';
import 'app_text_field.dart';
import 'date_field.dart';
import 'duration_stepper.dart';
import 'entry_modal.dart';

Future<void> showAddEntrySheet({
  required BuildContext context,
  Pillar? initialPillar,
  Project? initialProject,
  Workout? initialWorkout,
  void Function(Project project, WorkLog log)? onSaveWork,
  void Function(Workout workout)? onSaveHealth,
  void Function(MediaEntry entry)? onSaveLeisure,
}) {
  assert(
    switch (initialPillar) {
      null =>
        onSaveWork != null && onSaveHealth != null && onSaveLeisure != null,
      Pillar.work => onSaveWork != null,
      Pillar.health => onSaveHealth != null,
      Pillar.leisure => onSaveLeisure != null,
    },
    'showAddEntrySheet needs a save callback for every pillar the picker can land on.',
  );
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddEntrySheet(
      initialPillar: initialPillar,
      initialProject: initialProject,
      initialWorkout: initialWorkout,
      onSaveWork: onSaveWork,
      onSaveHealth: onSaveHealth,
      onSaveLeisure: onSaveLeisure,
    ),
  );
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({
    required this.initialPillar,
    required this.initialProject,
    required this.initialWorkout,
    required this.onSaveWork,
    required this.onSaveHealth,
    required this.onSaveLeisure,
  });

  final Pillar? initialPillar;
  final Project? initialProject;
  final Workout? initialWorkout;
  final void Function(Project project, WorkLog log)? onSaveWork;
  final void Function(Workout workout)? onSaveHealth;
  final void Function(MediaEntry entry)? onSaveLeisure;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  Pillar? _pillar;

  int _workMinutes = 60;
  DateTime _workDate = DateTime.now();
  bool _workTitleError = false;
  late final TextEditingController _workNewTitleController;

  late WorkoutType _healthType;
  late int _healthMinutes;
  late DateTime _healthDate;
  late final TextEditingController _healthNotesController;

  MediaType _leisureType = MediaType.book;
  bool _leisureTitleError = false;
  late final TextEditingController _leisureNewTitleController;

  @override
  void initState() {
    super.initState();
    _pillar = widget.initialPillar;

    _workNewTitleController = TextEditingController();

    _healthType = widget.initialWorkout?.type ?? WorkoutType.push;
    _healthMinutes = widget.initialWorkout?.durationMinutes ?? 45;
    _healthDate = widget.initialWorkout?.date ?? DateTime.now();
    _healthNotesController =
        TextEditingController(text: widget.initialWorkout?.notes ?? '');

    _leisureNewTitleController = TextEditingController();
  }

  @override
  void dispose() {
    _workNewTitleController.dispose();
    _healthNotesController.dispose();
    _leisureNewTitleController.dispose();
    super.dispose();
  }

  String _workoutLabel(WorkoutType t) {
    switch (t) {
      case WorkoutType.push:
        return 'Push';
      case WorkoutType.pull:
        return 'Pull';
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.cardio:
        return 'Cardio';
    }
  }

  String get _sheetTitle {
    switch (_pillar) {
      case null:
        return 'Log entry';
      case Pillar.work:
        return widget.initialProject == null ? 'New project' : 'Log hours';
      case Pillar.health:
        return widget.initialWorkout == null ? 'New workout' : 'Edit workout';
      case Pillar.leisure:
        return 'New title';
    }
  }

  void _save() {
    switch (_pillar) {
      case null:
        return;
      case Pillar.work:
        Project project;
        if (widget.initialProject != null) {
          project = widget.initialProject!;
        } else {
          final title = _workNewTitleController.text.trim();
          if (title.isEmpty) {
            setState(() => _workTitleError = true);
            return;
          }
          project = Project(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            subtitle: 'Personal',
            status: ProjectStatus.active,
          );
        }
        widget.onSaveWork?.call(
          project,
          WorkLog(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            projectId: project.id,
            hours: _workMinutes / 60,
            date: _workDate,
          ),
        );
        Navigator.of(context).pop();
      case Pillar.health:
        widget.onSaveHealth?.call(Workout(
          id: widget.initialWorkout?.id ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          type: _healthType,
          durationMinutes: _healthMinutes,
          date: _healthDate,
          notes: _healthNotesController.text.trim(),
          done: widget.initialWorkout?.done ?? false,
        ));
        Navigator.of(context).pop();
      case Pillar.leisure:
        final title = _leisureNewTitleController.text.trim();
        if (title.isEmpty) {
          setState(() => _leisureTitleError = true);
          return;
        }
        widget.onSaveLeisure?.call(
          MediaEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            type: _leisureType,
            status: MediaStatus.want,
          ),
        );
        Navigator.of(context).pop();
    }
  }

  List<Widget> _fieldsForPillar() {
    switch (_pillar) {
      case null:
        return [
          Text(
            'Choose a pillar above to log against.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ];
      case Pillar.work:
        return [
          if (widget.initialProject != null)
            LabelledField(
              label: 'Project',
              child: Text(
                widget.initialProject!.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            LabelledField(
              label: 'New project title',
              child: AppTextField(
                hint: 'e.g. Portfolio site',
                controller: _workNewTitleController,
                errorText: _workTitleError ? 'Enter a title' : null,
              ),
            ),
          LabelledField(
            label: 'Duration',
            child: DurationStepper(
              minutes: _workMinutes,
              onChanged: (v) => setState(() => _workMinutes = v),
            ),
          ),
          LabelledField(
            label: 'Date',
            child: DateField(
              value: _workDate,
              onChanged: (d) => setState(() => _workDate = d),
            ),
          ),
        ];
      case Pillar.health:
        return [
          LabelledField(
            label: 'Type',
            child: Wrap(
              spacing: AppSpacing.sm,
              children: WorkoutType.values.map((t) {
                return ChoiceChip(
                  label: Text(_workoutLabel(t)),
                  selected: _healthType == t,
                  onSelected: (_) => setState(() => _healthType = t),
                );
              }).toList(),
            ),
          ),
          LabelledField(
            label: 'Duration',
            child: DurationStepper(
              minutes: _healthMinutes,
              onChanged: (v) => setState(() => _healthMinutes = v),
            ),
          ),
          LabelledField(
            label: 'Notes',
            child: AppTextField(
              hint: 'e.g. Felt strong. Bench 3x8 at 60 kg.',
              controller: _healthNotesController,
              maxLines: 3,
            ),
          ),
          LabelledField(
            label: 'Date',
            child: DateField(
              value: _healthDate,
              onChanged: (d) => setState(() => _healthDate = d),
            ),
          ),
        ];
      case Pillar.leisure:
        return [
          LabelledField(
            label: 'New title',
            child: AppTextField(
              hint: 'e.g. Dune: Part Two',
              controller: _leisureNewTitleController,
              errorText: _leisureTitleError ? 'Enter a title' : null,
            ),
          ),
          LabelledField(
            label: 'Kind',
            child: Wrap(
              spacing: AppSpacing.sm,
              children: MediaType.values.map((t) {
                return ChoiceChip(
                  label: Text(t.label),
                  selected: _leisureType == t,
                  onSelected: (_) => setState(() => _leisureType = t),
                );
              }).toList(),
            ),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return EntryModal(
      pillar: _pillar,
      title: _sheetTitle,
      onCancel: () => Navigator.of(context).pop(),
      onSave: _pillar == null ? null : _save,
      fields: [
        if (widget.initialPillar == null)
          SegmentedButton<Pillar>(
            showSelectedIcon: false,
            expandedInsets: EdgeInsets.zero,
            emptySelectionAllowed: true,
            segments: const [
              ButtonSegment(value: Pillar.work, label: Text('Work')),
              ButtonSegment(value: Pillar.health, label: Text('Health')),
              ButtonSegment(value: Pillar.leisure, label: Text('Leisure')),
            ],
            selected: _pillar == null ? const {} : {_pillar!},
            onSelectionChanged: (s) =>
                setState(() => _pillar = s.isEmpty ? null : s.first),
          ),
        ..._fieldsForPillar(),
      ],
    );
  }
}
