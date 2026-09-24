import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../theme.dart';
import 'app_text_field.dart';
import 'duration_stepper.dart';
import 'entry_modal.dart';

Future<void> showHealthEntrySheet({
  required BuildContext context,
  required Workout? workout,
  required void Function(Workout w) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _HealthEntrySheet(initial: workout, onSave: onSave),
  );
}

class _HealthEntrySheet extends StatefulWidget {
  const _HealthEntrySheet({required this.initial, required this.onSave});

  final Workout? initial;
  final void Function(Workout w) onSave;

  @override
  State<_HealthEntrySheet> createState() => _HealthEntrySheetState();
}

class _HealthEntrySheetState extends State<_HealthEntrySheet> {
  late WorkoutType _type;
  late int _minutes;
  late DateTime _date;
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? WorkoutType.push;
    _minutes = widget.initial?.durationMinutes ?? 45;
    _date = widget.initial?.date ?? DateTime.now();
    _notesController = TextEditingController(text: widget.initial?.notes ?? '');
    _dateController = TextEditingController(text: _formatDate(_date));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

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

  String _label(WorkoutType t) {
    switch (t) {
      case WorkoutType.push:
        return 'Push';
      case WorkoutType.pull:
        return 'Pull';
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.run:
        return 'Run';
      case WorkoutType.swim:
        return 'Swim';
    }
  }

  @override
  Widget build(BuildContext context) {
    return EntryModal(
      pillar: Pillar.health,
      title: widget.initial == null ? 'New workout' : 'Edit workout',
      onCancel: () => Navigator.of(context).pop(),
      onSave: () {
        widget.onSave(Workout(
          id: widget.initial?.id ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          type: _type,
          durationMinutes: _minutes,
          date: _date,
          notes: _notesController.text.trim(),
        ));
        Navigator.of(context).pop();
      },
      fields: [
        LabelledField(
          label: 'Type',
          child: Wrap(
            spacing: AppSpacing.sm,
            children: WorkoutType.values.map((t) {
              return ChoiceChip(
                label: Text(_label(t)),
                selected: _type == t,
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
        ),
        LabelledField(
          label: 'Duration',
          child: DurationStepper(
            value: _minutes,
            step: 5,
            unit: 'min',
            onChanged: (v) => setState(() => _minutes = v.toInt()),
          ),
        ),
        LabelledField(
          label: 'Notes',
          child: AppTextField(
            hint: 'e.g. Felt strong. Bench 3x8 at 60 kg.',
            controller: _notesController,
            maxLines: 3,
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
