import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../theme.dart';

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
        final percent =
            (entry.currentPage / entry.totalPages * 100).clamp(0, 100);
        return '${percent.round()}%';
      case MediaType.film:
      case MediaType.series:
        return '${_hm(entry.stoppedMinutes)} / ${_hm(entry.totalMinutes)}';
      case MediaType.game:
        return _hm(entry.durationMinutes);
    }
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
    final accent = context.pillars.of(Pillar.leisure);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: theme.textTheme.bodyMedium),
                    if (entry.status != MediaStatus.want) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${entry.type.label} · ${entry.status.label}',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.secondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: switch (entry.status) {
                MediaStatus.want => Text(
                    entry.type.label,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.secondary),
                  ),
                MediaStatus.inProgress =>
                  Text(_progress, style: theme.textTheme.labelLarge),
                MediaStatus.done =>
                  _Stars(rating: entry.rating ?? 0, color: accent),
              },
            ),
          ],
        ),
      ),
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
          Icon(i <= rating ? Icons.star : Icons.star_border,
              size: 16, color: color),
      ],
    );
  }
}
