import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/caption.dart';
import '../widgets/date_field.dart';
import '../widgets/duration_stepper.dart';
import '../widgets/number_stepper.dart';
import '../widgets/screen_header.dart';

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

  void _update(MediaEntry Function(MediaEntry) change) {
    setState(() => _entry = change(_entry));
    widget.onUpdate(_entry);
  }

  Future<void> _setTracked(int minutes) async {
    final delta = minutes - _entry.trackedMinutes;
    _update((e) => e.withTrackedMinutes(minutes));
    if (delta == 0) return;

    final now = DateTime.now();
    final i = _allLogs
        .indexWhere((l) => l.mediaId == _entry.id && isSameDay(l.date, now));
    if (i == -1) {
      _allLogs = [
        ..._allLogs,
        LeisureLog(
          id: now.microsecondsSinceEpoch.toString(),
          mediaId: _entry.id,
          minutes: delta,
          date: now,
        ),
      ];
    } else {
      final old = _allLogs[i];
      final total = old.minutes + delta;
      _allLogs = [
        for (var j = 0; j < _allLogs.length; j++)
          if (j != i)
            _allLogs[j]
          else if (total != 0)
            LeisureLog(
                id: old.id,
                mediaId: old.mediaId,
                minutes: total,
                date: old.date),
      ];
    }
    await _logStore.save(_allLogs);
  }

  Future<void> _setStatus(MediaStatus status) async {
    if (status != MediaStatus.want) {
      _update((e) => e.copyWith(status: status));
      return;
    }
    _update((e) => e.copyWith(
          status: status,
          durationMinutes: 0,
          currentPage: 0,
          stoppedMinutes: 0,
          currentSeason: 1,
          currentEpisode: 1,
        ));
    _allLogs = _allLogs.where((l) => l.mediaId != _entry.id).toList();
    await _logStore.save(_allLogs);
  }

  void _saveNotes() {
    _update((e) => e.copyWith(notes: _notesController.text.trim()));
  }

  Widget _field(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Caption(label),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      );

  Widget _pair(
          String leftLabel, Widget left, String rightLabel, Widget right) =>
      Row(
        children: [
          Expanded(child: _field(leftLabel, left)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _field(rightLabel, right)),
        ],
      );

  @override
  Widget build(BuildContext context) {
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
                    Caption(_entry.type.label),
                    const SizedBox(height: AppSpacing.lg),
                    const Caption('STATUS'),
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
                    ..._fieldsForStatus(),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _fieldsForStatus() {
    switch (_entry.status) {
      case MediaStatus.want:
        return [
          _field(
            'NOTES',
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Why this is on the list, or anything to remember',
              ),
              onEditingComplete: _saveNotes,
              onTapOutside: (_) => _saveNotes(),
            ),
          ),
        ];
      case MediaStatus.inProgress:
        return _progressFields();
      case MediaStatus.done:
        final accent = context.pillars.of(Pillar.leisure);
        return [
          _field(
            'RATING',
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      i <= (_entry.rating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: accent,
                    ),
                    onPressed: () => _update((e) => e.copyWith(rating: i)),
                  ),
              ],
            ),
          ),
          _field(
            'REVIEW',
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration:
                  const InputDecoration(hintText: 'What did you think?'),
              onEditingComplete: _saveNotes,
              onTapOutside: (_) => _saveNotes(),
            ),
          ),
        ];
    }
  }

  List<Widget> _progressFields() {
    final stopped = _field(
      'WHERE YOU STOPPED',
      DurationStepper(minutes: _entry.stoppedMinutes, onChanged: _setTracked),
    );
    final total = _field(
      'TOTAL DURATION',
      DurationStepper(
        minutes: _entry.totalMinutes,
        onChanged: (v) => _update((e) => e.copyWith(totalMinutes: v)),
      ),
    );
    final timeSpent = _field(
      'DURATION',
      DurationStepper(minutes: _entry.durationMinutes, onChanged: _setTracked),
    );

    switch (_entry.type) {
      case MediaType.book:
        return [
          _pair(
            'CURRENT PAGE',
            NumberStepper(
              value: _entry.currentPage,
              onChanged: (v) => _update((e) => e.copyWith(currentPage: v)),
            ),
            'TOTAL PAGES',
            NumberStepper(
              value: _entry.totalPages,
              onChanged: (v) => _update((e) => e.copyWith(totalPages: v)),
            ),
          ),
          timeSpent,
        ];
      case MediaType.film:
        return [stopped, total];
      case MediaType.series:
        return [
          _pair(
            'CURRENT SEASON',
            NumberStepper(
              value: _entry.currentSeason,
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(currentSeason: v)),
            ),
            'TOTAL SEASONS',
            NumberStepper(
              value: _entry.totalSeasons,
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(totalSeasons: v)),
            ),
          ),
          _pair(
            'CURRENT EPISODE',
            NumberStepper(
              value: _entry.currentEpisode,
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(currentEpisode: v)),
            ),
            'TOTAL EPISODES',
            NumberStepper(
              value: _entry.totalEpisodes,
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(totalEpisodes: v)),
            ),
          ),
          stopped,
          total,
        ];
      case MediaType.game:
        return [timeSpent];
    }
  }
}
