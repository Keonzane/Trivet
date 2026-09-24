import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../theme.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.entry,
    this.progress,
    this.rating,
    required this.onTap,
  });

  final MediaEntry entry;

  final String? progress;
  final int? rating;
  final VoidCallback onTap;

  String get _kindLabel {
    switch (entry.type) {
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

  String get _statusLabel {
    switch (entry.status) {
      case MediaStatus.want:
        return 'Want to start';
      case MediaStatus.inProgress:
        return 'In progress';
      case MediaStatus.done:
        return 'Done';
    }
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$_kindLabel · $_statusLabel',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.secondary),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: rating != null
                  ? _Stars(rating: rating!, color: accent)
                  : Text(progress ?? '', style: theme.textTheme.labelLarge),
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
