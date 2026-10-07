import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/caption.dart';
import '../widgets/choice_bar.dart';
import '../widgets/date_field.dart';
import '../widgets/detail_scaffold.dart';
import '../widgets/duration_stepper.dart';
import '../widgets/entry_modal.dart';
import '../widgets/number_stepper.dart';

class MediaDetailScreen extends StatefulWidget {
  const MediaDetailScreen({super.key, required this.entry});

  final MediaEntry entry;

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final _mediaStore = MediaStore();
  final _logStore = LeisureLogStore();
  late MediaEntry _entry = widget.entry;
  late final _notesController = TextEditingController(text: _entry.notes);
  late final _reviewController = TextEditingController(text: _entry.review);
  List<LeisureLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final logs = await _logStore.load();
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  void _update(MediaEntry Function(MediaEntry) change) {
    setState(() => _entry = change(_entry));
    _mediaStore.put(_entry);
  }

  Future<void> _setTracked(int minutes) async {
    final delta = minutes - _entry.trackedMinutes;
    _update((e) => e.withTrackedMinutes(minutes));
    if (delta == 0) return;

    final now = DateTime.now();
    final i = _logs
        .indexWhere((l) => l.mediaId == _entry.id && isSameDay(l.date, now));
    if (i == -1) {
      _logs.add(LeisureLog(
        id: now.microsecondsSinceEpoch.toString(),
        mediaId: _entry.id,
        minutes: delta,
        date: now,
      ));
    } else {
      final old = _logs[i];
      final total = old.minutes + delta;
      if (total == 0) {
        _logs.removeAt(i);
      } else {
        _logs[i] = LeisureLog(
            id: old.id, mediaId: old.mediaId, minutes: total, date: old.date);
      }
    }
    await _logStore.save(_logs);
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
    _logs.removeWhere((l) => l.mediaId == _entry.id);
    await _logStore.save(_logs);
  }

  Widget _field(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: LabelledField(label: label, child: child),
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
    return DetailScaffold(
      title: _entry.title,
      loading: _loading,
      children: [
        Caption(_entry.type.label),
        const SizedBox(height: AppSpacing.lg),
        _field(
          'Status',
          ChoiceBar<MediaStatus>(
            values: MediaStatus.values,
            selected: _entry.status,
            labelOf: (s) => s.label,
            onSelected: _setStatus,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._fieldsForStatus(),
      ],
    );
  }

  List<Widget> _fieldsForStatus() {
    switch (_entry.status) {
      case MediaStatus.want:
        return [
          _field(
            'Notes',
            AppTextField(
              hint: 'Why this is on the list, or anything to remember',
              controller: _notesController,
              maxLines: 3,
              onChanged: (t) => _update((e) => e.copyWith(notes: t.trim())),
            ),
          ),
        ];
      case MediaStatus.inProgress:
        return _progressFields();
      case MediaStatus.done:
        final accent = context.pillars.of(Pillar.leisure);
        return [
          _field(
            'Rating',
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
            'Review',
            AppTextField(
              hint: 'What did you think?',
              controller: _reviewController,
              maxLines: 4,
              onChanged: (t) => _update((e) => e.copyWith(review: t.trim())),
            ),
          ),
        ];
    }
  }

  List<Widget> _progressFields() {
    final stopped = _field(
      'Where you stopped',
      DurationStepper(
        minutes: _entry.stoppedMinutes,
        max: _entry.totalMinutes,
        onChanged: _setTracked,
      ),
    );
    final total = _field(
      'Total duration',
      DurationStepper(
        minutes: _entry.totalMinutes,
        onChanged: (v) {
          _update((e) => e.copyWith(totalMinutes: v));
          if (_entry.stoppedMinutes > v) _setTracked(v);
        },
      ),
    );
    final timeSpent = _field(
      'Duration',
      DurationStepper(minutes: _entry.durationMinutes, onChanged: _setTracked),
    );

    switch (_entry.type) {
      case MediaType.book:
        return [
          _pair(
            'Current page',
            NumberStepper(
              value: _entry.currentPage,
              max: _entry.totalPages,
              onChanged: (v) => _update((e) => e.copyWith(currentPage: v)),
            ),
            'Total pages',
            NumberStepper(
              value: _entry.totalPages,
              onChanged: (v) => _update((e) => e.copyWith(
                    totalPages: v,
                    currentPage: e.currentPage > v ? v : e.currentPage,
                  )),
            ),
          ),
          timeSpent,
        ];
      case MediaType.film:
        return [stopped, total];
      case MediaType.series:
        return [
          _pair(
            'Current season',
            NumberStepper(
              value: _entry.currentSeason,
              min: 1,
              max: _entry.totalSeasons,
              onChanged: (v) => _update((e) => e.copyWith(currentSeason: v)),
            ),
            'Total seasons',
            NumberStepper(
              value: _entry.totalSeasons,
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(
                    totalSeasons: v,
                    currentSeason: e.currentSeason > v ? v : e.currentSeason,
                  )),
            ),
          ),
          _pair(
            'Current episode',
            NumberStepper(
              value: _entry.currentEpisode,
              min: 1,
              max: _entry.totalEpisodes,
              onChanged: (v) => _update((e) => e.copyWith(currentEpisode: v)),
            ),
            'Total episodes',
            NumberStepper(
              value: _entry.totalEpisodes,
              min: 1,
              onChanged: (v) => _update((e) => e.copyWith(
                    totalEpisodes: v,
                    currentEpisode: e.currentEpisode > v ? v : e.currentEpisode,
                  )),
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
