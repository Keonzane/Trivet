import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../theme.dart';
import 'app_text_field.dart';
import 'duration_stepper.dart';
import 'entry_modal.dart';

const _newTitleId = '__new__';

Future<void> showLeisureEntrySheet({
  required BuildContext context,
  required List<MediaEntry> entries,
  required MediaEntry? entry,
  required void Function(MediaEntry entry, LeisureLog log) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _LeisureEntrySheet(
      entries: entries,
      initialEntry: entry,
      onSave: onSave,
    ),
  );
}

class _LeisureEntrySheet extends StatefulWidget {
  const _LeisureEntrySheet({
    required this.entries,
    required this.initialEntry,
    required this.onSave,
  });

  final List<MediaEntry> entries;
  final MediaEntry? initialEntry;
  final void Function(MediaEntry entry, LeisureLog log) onSave;

  @override
  State<_LeisureEntrySheet> createState() => _LeisureEntrySheetState();
}

class _LeisureEntrySheetState extends State<_LeisureEntrySheet> {
  late String _selectedId;
  MediaType _type = MediaType.book;
  int _minutes = 30;
  DateTime _date = DateTime.now();
  bool _showTitleError = false;
  late final TextEditingController _newTitleController;
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialEntry?.id ??
        (widget.entries.isNotEmpty ? widget.entries.first.id : _newTitleId);
    _newTitleController = TextEditingController();
    _dateController = TextEditingController(text: _formatDate(_date));
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  bool get _isNew => _selectedId == _newTitleId;

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

  String _label(MediaType t) {
    switch (t) {
      case MediaType.book:
        return 'Book';
      case MediaType.film:
        return 'Film';
      case MediaType.series:
        return 'Series';
      case MediaType.game:
        return 'Game';
    }
  }

  void _save() {
    MediaEntry entry;
    if (_isNew) {
      final title = _newTitleController.text.trim();
      if (title.isEmpty) {
        setState(() => _showTitleError = true);
        return;
      }
      entry = MediaEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        type: _type,
        status: MediaStatus.inProgress,
      );
    } else {
      entry = widget.entries.firstWhere((e) => e.id == _selectedId);
    }
    widget.onSave(
      entry,
      LeisureLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mediaId: entry.id,
        minutes: _minutes,
        date: _date,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return EntryModal(
      pillar: Pillar.leisure,
      title: 'Log time',
      onCancel: () => Navigator.of(context).pop(),
      onSave: _save,
      fields: [
        LabelledField(
          label: 'Title',
          child: DropdownButtonFormField<String>(
            value: _selectedId,
            isExpanded: true,
            items: [
              for (final e in widget.entries)
                DropdownMenuItem(value: e.id, child: Text(e.title)),
              const DropdownMenuItem(
                  value: _newTitleId, child: Text('+ New title')),
            ],
            onChanged: (id) => setState(() {
              _selectedId = id!;
              _showTitleError = false;
            }),
          ),
        ),
        if (_isNew) ...[
          LabelledField(
            label: 'New title',
            child: AppTextField(
              hint: 'e.g. Dune: Part Two',
              controller: _newTitleController,
              errorText: _showTitleError ? 'Enter a title' : null,
            ),
          ),
          LabelledField(
            label: 'Kind',
            child: Wrap(
              spacing: AppSpacing.sm,
              children: MediaType.values.map((t) {
                return ChoiceChip(
                  label: Text(_label(t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),
          ),
        ],
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
