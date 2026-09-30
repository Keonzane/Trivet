import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/add_entry_sheet.dart';
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
  List<LeisureLog> _allLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _load();
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

  void _setStatus(MediaStatus status) {
    setState(() => _entry = _entry.copyWith(status: status));
    widget.onUpdate(_entry);
  }

  void _setRating(int rating) {
    setState(() => _entry = _entry.copyWith(rating: rating));
    widget.onUpdate(_entry);
  }

  Future<void> _logMoreTime() async {
    await showAddEntrySheet(
      context: context,
      initialPillar: Pillar.leisure,
      initialMediaEntry: _entry,
      onSaveLeisure: (entry, log) async {
        _allLogs = [..._allLogs, log];
        await _logStore.save(_allLogs);
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = context.pillars.of(Pillar.leisure);

    return Scaffold(
      appBar: AppBar(title: Text(_entry.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _entry.type.label,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_totalHours.toStringAsFixed(1)} h logged in total',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'STATUS',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<MediaStatus>(
                      showSelectedIcon: false,
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
                    Text(
                      'RATING',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                            onPressed: () => _setRating(i),
                          ),
                      ],
                    ),
                    const Spacer(),
                    PillarButton(
                      pillar: Pillar.leisure,
                      label: '+ Log time',
                      onPressed: _logMoreTime,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
