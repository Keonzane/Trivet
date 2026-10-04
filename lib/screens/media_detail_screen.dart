import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/duration_stepper.dart';
import '../widgets/pillar_button.dart';

class MediaDetailScreen extends StatefulWidget {
  const MediaDetailScreen(
      {super.key, required this.entry, required this.onUpdate});

  final MediaEntry entry;

  final ValueChanged<MediaEntry> onUpdate;

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final _logStore = LeisureLogStore();
  late MediaEntry _entry;
  late final TextEditingController _notesController;
  List<LeisureLog> _allLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _notesController = TextEditingController(text: _entry.notes);
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

  List<LeisureLog> get _entryLogs =>
      _allLogs.where((l) => l.mediaId == _entry.id).toList();

  double get _totalHours =>
      _entryLogs.fold(0, (sum, l) => sum + l.minutes) / 60;

  void _update(MediaEntry Function(MediaEntry) change) {
    setState(() => _entry = change(_entry));
    widget.onUpdate(_entry);
  }

  void _setStatus(MediaStatus status) {
    _update((e) => status == MediaStatus.want
        ? e.copyWith(
            status: status, durationMinutes: 0, pages: 0, season: 1, episode: 1)
        : e.copyWith(status: status));
  }

  void _saveNotes() {
    _update((e) => e.copyWith(notes: _notesController.text.trim()));
  }

  Future<void> _logMoreTime() async {
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.leisure,
      initialMediaEntry: _entry,
      onSaveLeisure: (entry, log) async {
        if (log == null) return;
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
    final accent = context.pillars.of(Pillar.leisure);

    return Scaffold(
      appBar: AppBar(
        title: Text(_entry.title),
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
                    _caption(theme, _entry.type.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_totalHours.toStringAsFixed(1)} h logged in total',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _caption(theme, 'STATUS'),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<MediaStatus>(
                      showSelectedIcon: false,
                      expandedInsets: EdgeInsets.zero,
                      segments: const [
                        ButtonSegment(
                            value: MediaStatus.want, label: Text('Want')),
                        ButtonSegment(
                            value: MediaStatus.inProgress,
                            label: Text('In progress')),
                        ButtonSegment(
                            value: MediaStatus.done, label: Text('Done')),
                      ],
                      selected: {_entry.status},
                      onSelectionChanged: (s) => _setStatus(s.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ..._fieldsForStatus(theme, accent),
                    const SizedBox(height: AppSpacing.lg),
                    PillarButton(
                      pillar: Pillar.leisure,
                      label: '+ Log time',
                      onPressed: _logMoreTime,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _fieldsForStatus(ThemeData theme, Color accent) {
    switch (_entry.status) {
      case MediaStatus.want:
        return [
          _caption(theme, 'NOTES'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Why this is on the list, or anything to remember'),
            onEditingComplete: _saveNotes,
            onTapOutside: (_) => _saveNotes(),
          ),
        ];
      case MediaStatus.inProgress:
        return [
          _caption(theme, 'DURATION'),
          const SizedBox(height: AppSpacing.sm),
          DurationStepper(
            value: _entry.durationMinutes,
            step: 5,
            unit: 'min',
            onChanged: (v) =>
                _update((e) => e.copyWith(durationMinutes: v.toInt())),
          ),
          if (_entry.type == MediaType.book) ...[
            const SizedBox(height: AppSpacing.md),
            _caption(theme, 'PAGES'),
            const SizedBox(height: AppSpacing.sm),
            DurationStepper(
              value: _entry.pages,
              step: 1,
              unit: 'pages',
              onChanged: (v) => _update((e) => e.copyWith(pages: v.toInt())),
            ),
          ],
          if (_entry.type == MediaType.series) ...[
            const SizedBox(height: AppSpacing.md),
            _caption(theme, 'SEASON'),
            const SizedBox(height: AppSpacing.sm),
            DurationStepper(
              value: _entry.season,
              step: 1,
              unit: 'season',
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(season: v.toInt())),
            ),
            const SizedBox(height: AppSpacing.md),
            _caption(theme, 'EPISODE'),
            const SizedBox(height: AppSpacing.sm),
            DurationStepper(
              value: _entry.episode,
              step: 1,
              unit: 'episode',
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(episode: v.toInt())),
            ),
          ],
        ];
      case MediaStatus.done:
        return [
          _caption(theme, 'RATING'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    i <= (_entry.rating ?? 0) ? Icons.star : Icons.star_border,
                    color: accent,
                  ),
                  onPressed: () => _update((e) => e.copyWith(rating: i)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _caption(theme, 'REVIEW'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'What did you think?'),
            onEditingComplete: _saveNotes,
            onTapOutside: (_) => _saveNotes(),
          ),
        ];
    }
  }
}
