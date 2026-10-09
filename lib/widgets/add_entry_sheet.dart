import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/media_entry.dart';
import '../models/media_result.dart';
import '../models/project.dart';
import '../models/work_log.dart';
import '../models/workout.dart';
import '../services/media_search/media_search_service.dart';
import '../services/media_search/rawg_provider.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'app_text_field.dart';
import 'choice_bar.dart';
import 'date_field.dart';
import 'duration_stepper.dart';
import 'entry_modal.dart';

Future<void> showAddEntrySheet({
  required BuildContext context,
  Pillar? initialPillar,
  Project? initialProject,
  Workout? initialWorkout,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddEntrySheet(
      initialPillar: initialPillar,
      initialProject: initialProject,
      initialWorkout: initialWorkout,
    ),
  );
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({
    required this.initialPillar,
    required this.initialProject,
    required this.initialWorkout,
  });

  final Pillar? initialPillar;
  final Project? initialProject;
  final Workout? initialWorkout;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  late Pillar? _pillar = widget.initialPillar;

  int _workMinutes = 60;
  DateTime? _workDueDate;
  bool _workTitleError = false;
  final _workNewTitleController = TextEditingController();

  late WorkoutType _healthType =
      widget.initialWorkout?.type ?? WorkoutType.push;
  late int _healthMinutes = widget.initialWorkout?.durationMinutes ?? 45;
  late DateTime _healthDate = widget.initialWorkout?.date ?? DateTime.now();
  late final _healthNotesController =
      TextEditingController(text: widget.initialWorkout?.notes ?? '');

  MediaType _leisureType = MediaType.book;
  bool _leisureTitleError = false;
  final _leisureNewTitleController = TextEditingController();
  final _search = MediaSearchService.instance;
  Timer? _searchDebounce;
  int _searchSeq = 0;
  List<MediaResult> _suggestions = [];
  bool _searching = false;
  MediaResult? _picked;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _workNewTitleController.dispose();
    _healthNotesController.dispose();
    _leisureNewTitleController.dispose();
    super.dispose();
  }

  Widget _chips<T>(List<T> values, T selected, String Function(T) labelOf,
      ValueChanged<T> onPick) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(labelOf(v)),
            selected: selected == v,
            onSelected: (_) => setState(() => onPick(v)),
          ),
      ],
    );
  }

  void _queueSearch() {
    _searchDebounce?.cancel();
    final text = _leisureNewTitleController.text.trim();
    if (_picked != null ||
        !_search.canSearch(_leisureType) ||
        text.length < 2) {
      _suggestions = [];
      _searching = false;
      return;
    }
    _searching = true;
    _searchDebounce = Timer(const Duration(milliseconds: 400), _runSearch);
  }

  void _onLeisureTitleChanged(String text) {
    setState(() {
      if (_picked != null && text.trim() != _picked!.title) _picked = null;
      _queueSearch();
    });
  }

  Future<void> _runSearch() async {
    final seq = ++_searchSeq;
    final results = await _search.search(
      _leisureNewTitleController.text,
      type: _leisureType,
    );
    if (!mounted || seq != _searchSeq) return;
    setState(() {
      _suggestions = results;
      _searching = false;
    });
  }

  Future<void> _pickSuggestion(MediaResult result) async {
    _searchDebounce?.cancel();
    _searchSeq++;
    setState(() {
      _picked = result;
      _leisureType = result.type;
      _suggestions = [];
      _searching = false;
      _leisureTitleError = false;
      _leisureNewTitleController.text = result.title;
    });
    final detailed = await _search.enrich(result);
    if (!mounted || _picked?.key != result.key) return;
    _picked = detailed;
  }

  Widget _suggestionList() {
    final theme = Theme.of(context);
    final hint = _picked == null ? _search.setupHint(_leisureType) : null;
    if (hint != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          hint,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.secondary),
        ),
      );
    }
    if (_searching && _suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(),
      );
    }
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    final showRawgCredit = _suggestions.any((r) => r.source == 'rawg');
    final list = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final r in _suggestions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: _Poster(url: r.posterUrl),
              title:
                  Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                [
                  if (r.year != null) '${r.year}',
                  if (r.subtitle != null) r.subtitle!,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.secondary),
              ),
              onTap: () => _pickSuggestion(r),
            ),
        ],
      ),
    );
    if (!showRawgCredit) return list;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        list,
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => launchUrl(
            RawgProvider.creditUrl,
            mode: LaunchMode.externalApplication,
          ),
          child: Text(
            RawgProvider.creditText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
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

  Future<void> _save() async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    switch (_pillar) {
      case null:
        return;
      case Pillar.work:
        var project = widget.initialProject;
        if (project == null) {
          final title = _workNewTitleController.text.trim();
          if (title.isEmpty) {
            setState(() => _workTitleError = true);
            return;
          }
          project = Project(
            id: id,
            title: title,
            status: ProjectStatus.active,
            dueDate: _workDueDate,
          );
          await ProjectStore().put(project);
        }
        if (_workMinutes > 0) {
          await WorkLogStore().put(WorkLog(
            id: id,
            projectId: project.id,
            hours: _workMinutes / 60,
            date: DateTime.now(),
          ));
        }
      case Pillar.health:
        await WorkoutStore().put(Workout(
          id: widget.initialWorkout?.id ?? id,
          type: _healthType,
          durationMinutes: _healthMinutes,
          date: _healthDate,
          notes: _healthNotesController.text.trim(),
          done: widget.initialWorkout?.done ?? false,
          completedAt: widget.initialWorkout?.completedAt,
        ));
      case Pillar.leisure:
        final title = _leisureNewTitleController.text.trim();
        if (title.isEmpty) {
          setState(() => _leisureTitleError = true);
          return;
        }
        await MediaStore().put(
          _picked?.toEntry(id: id, title: title) ??
              MediaEntry(
                  id: id,
                  title: title,
                  type: _leisureType,
                  status: MediaStatus.want),
        );
    }
    if (mounted) Navigator.of(context).pop();
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
          else ...[
            LabelledField(
              label: 'New project title',
              child: AppTextField(
                hint: 'e.g. Portfolio site',
                controller: _workNewTitleController,
                errorText: _workTitleError ? 'Enter a title' : null,
              ),
            ),
            LabelledField(
              label: 'Due date',
              child: DateField(
                value: _workDueDate,
                onChanged: (d) => setState(() => _workDueDate = d),
                onClear: () => setState(() => _workDueDate = null),
              ),
            ),
          ],
          LabelledField(
            label: 'Duration',
            child: DurationStepper(
              minutes: _workMinutes,
              onChanged: (v) => setState(() => _workMinutes = v),
            ),
          ),
        ];
      case Pillar.health:
        return [
          LabelledField(
            label: 'Type',
            child: _chips(WorkoutType.values, _healthType, (t) => t.label,
                (t) => _healthType = t),
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
              onChanged: _onLeisureTitleChanged,
            ),
          ),
          LabelledField(
            label: 'Kind',
            child: _chips(MediaType.values, _leisureType, (t) => t.label, (t) {
              _leisureType = t;
              _picked = null;
              _queueSearch();
            }),
          ),
          _suggestionList(),
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
          ChoiceBar<Pillar>(
            values: Pillar.values,
            selected: _pillar,
            labelOf: (p) => p.label,
            onSelected: (p) => setState(() => _pillar = p),
          ),
        ..._fieldsForPillar(),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 32,
      height: 48,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined, size: 16),
    );
    if (url == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url!,
        width: 32,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
