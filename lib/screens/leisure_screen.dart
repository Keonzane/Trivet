import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/leisure_entry_sheet.dart';
import '../widgets/media_card.dart';
import '../widgets/pillar_button.dart';

class LeisureScreen extends StatefulWidget {
  const LeisureScreen({super.key});

  @override
  State<LeisureScreen> createState() => _LeisureScreenState();
}

class _LeisureScreenState extends State<LeisureScreen> {
  final _mediaStore = MediaStore();
  final _logStore = LeisureLogStore();

  List<MediaEntry> _entries = [];
  List<LeisureLog> _logs = [];
  MediaStatus _filter = MediaStatus.want;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _mediaStore.load();
    final logs = await _logStore.load();
    setState(() {
      _entries = entries;
      _logs = logs;
      _loading = false;
    });
  }

  double _hoursThisWeek(String mediaId) {
    final week = WeekRange.containing(DateTime.now());
    final minutes = _logs
        .where((l) => l.mediaId == mediaId && week.contains(l.date))
        .fold(0, (sum, l) => sum + l.minutes);
    return minutes / 60;
  }

  Future<void> _logTime(MediaEntry? entry) async {
    await showLeisureEntrySheet(
      context: context,
      entries: _entries,
      entry: entry,
      onSave: (entry, log) async {
        setState(() {
          if (!_entries.any((e) => e.id == entry.id)) {
            _entries = [..._entries, entry];
          }
          _logs = [..._logs, log];
        });
        await _mediaStore.save(_entries);
        await _logStore.save(_logs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _entries.where((e) => e.status == _filter).toList();
    final weekTotal = _entries.fold<double>(0, (sum, e) => sum + _hoursThisWeek(e.id));
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${weekTotal.toStringAsFixed(1)}H THIS WEEK',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Books & media', style: theme.textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<MediaStatus>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: MediaStatus.want, label: Text('Want')),
                  ButtonSegment(value: MediaStatus.inProgress, label: Text('In progress')),
                  ButtonSegment(value: MediaStatus.done, label: Text('Done')),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        message: _entries.isEmpty
                            ? 'No titles yet. Add one to start logging time.'
                            : 'Nothing here yet.',
                        icon: Icons.menu_book_outlined,
                        actionLabel: _entries.isEmpty ? '+ Add title' : null,
                        onAction: _entries.isEmpty ? () => _logTime(null) : null,
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) {
                          final e = filtered[i];
                          final hours = _hoursThisWeek(e.id);
                          return MediaCard(
                            entry: e,
                            progress: '${hours.toStringAsFixed(1)} h',
                            rating: e.rating,
                            onTap: () => _logTime(e),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              PillarButton(
                pillar: Pillar.leisure,
                label: '+ Add title',
                onPressed: () => _logTime(null),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
