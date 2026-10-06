import 'package:flutter/material.dart';

import '../models/leisure_log.dart';
import '../models/media_entry.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/add_entry_sheet.dart';
import '../widgets/dismissible_row.dart';
import '../widgets/empty_state.dart';
import '../widgets/media_card.dart';
import '../widgets/pillar_button.dart';
import '../widgets/sectioned_list.dart';
import 'media_detail_screen.dart';

class LeisureScreen extends StatefulWidget {
  const LeisureScreen({super.key, this.initialFilter});

  final MediaStatus? initialFilter;

  @override
  State<LeisureScreen> createState() => _LeisureScreenState();
}

class _LeisureScreenState extends State<LeisureScreen> {
  final _mediaStore = MediaStore();
  final _logStore = LeisureLogStore();

  List<MediaEntry> _entries = [];
  List<LeisureLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _mediaStore.load();
    final logs = await _logStore.load();
    if (!mounted) return;
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

  Future<void> _addTitle() async {
    await showAddEntrySheet(context: context, initialPillar: Pillar.leisure);
    await _load();
  }

  Future<void> _deleteTitle(MediaEntry e) async {
    setState(() {
      _entries = _entries.where((x) => x.id != e.id).toList();
      _logs = _logs.where((l) => l.mediaId != e.id).toList();
    });
    await _mediaStore.save(_entries);
    await _logStore.save(_logs);
  }

  Future<void> _openDetail(MediaEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MediaDetailScreen(entry: entry)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final weekTotal =
        _entries.fold<double>(0, (sum, e) => sum + _hoursThisWeek(e.id));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                caption: '${weekTotal.toStringAsFixed(1)}H THIS WEEK',
                title: 'Books & media',
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _entries.isEmpty
                    ? EmptyState(
                        message: 'No titles yet. Add one to start tracking it.',
                        icon: Icons.menu_book_outlined,
                        actionLabel: '+ Add title',
                        onAction: _addTitle,
                      )
                    : SectionedList<MediaStatus>(
                        sections: MediaStatus.values,
                        initial: widget.initialFilter ?? MediaStatus.want,
                        labelOf: (s) => s.label,
                        itemsOf: (s) => [
                          for (final e in _entries.where((e) => e.status == s))
                            DismissibleRow(
                              itemKey: ValueKey(e.id),
                              title: e.title,
                              confirmMessage:
                                  'This also removes the time recorded for this title.',
                              onDelete: () => _deleteTitle(e),
                              child: MediaCard(
                                entry: e,
                                onTap: () => _openDetail(e),
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              PillarButton(
                pillar: Pillar.leisure,
                label: '+ Add title',
                onPressed: _addTitle,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
