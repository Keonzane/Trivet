import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../theme.dart';
import 'pillar_card.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final MediaEntry entry;

  final VoidCallback onTap;

  String get _progress {
    switch (entry.type) {
      case MediaType.book:
        if (entry.totalPages == 0) return '0%';
        final percent = (entry.currentPage / entry.totalPages * 100).clamp(0, 100);
        return '${percent.round()}%';
      case MediaType.film:
      case MediaType.series:
        return '${_hm(entry.stoppedMinutes)} / ${_hm(entry.totalMinutes)}';
      case MediaType.game:
        return _hm(entry.durationMinutes);
    }
  }

  String get _subtitle {
    if (entry.status == MediaStatus.inProgress) {
      switch (entry.type) {
        case MediaType.book:
          return 'Book · Page ${entry.currentPage} / ${entry.totalPages}';
        case MediaType.series:
          return 'Series · Season ${entry.currentSeason} · Episode ${entry.currentEpisode}';
        case MediaType.film:
        case MediaType.game:
          break;
      }
    }
    return entry.type.label;
  }

  String _hm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PillarCard(
      pillar: Pillar.leisure,
      title: entry.title,
      subtitle: entry.status == MediaStatus.want ? null : _subtitle,
      onTap: onTap,
      trailing: switch (entry.status) {
        MediaStatus.want => Text(
            entry.type.label,
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary),
          ),
        MediaStatus.inProgress => Text(_progress, style: theme.textTheme.labelLarge),
        MediaStatus.done => _Stars(
            rating: entry.rating ?? 0,
            color: context.pillars.of(Pillar.leisure),
          ),
      },
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.color});

  final int rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(i <= rating ? Icons.star : Icons.star_border, size: 16, color: color),
      ],
    );
  }
}
