import 'media_entry.dart';

class MediaResult {
  final String source;
  final String sourceId;
  final MediaType type;
  final String title;
  final int? year;
  final String? posterUrl;
  final double? rating;
  final String? subtitle;
  final Map<String, String> externalIds;

  final int totalPages;
  final int totalMinutes;
  final int totalSeasons;
  final int totalEpisodes;

  const MediaResult({
    required this.source,
    required this.sourceId,
    required this.type,
    required this.title,
    this.year,
    this.posterUrl,
    this.rating,
    this.subtitle,
    this.externalIds = const {},
    this.totalPages = 0,
    this.totalMinutes = 0,
    this.totalSeasons = 1,
    this.totalEpisodes = 1,
  });

  String get key => '$source:$sourceId';

  MediaResult copyWith({
    int? totalPages,
    int? totalMinutes,
    int? totalSeasons,
    int? totalEpisodes,
  }) =>
      MediaResult(
        source: source,
        sourceId: sourceId,
        type: type,
        title: title,
        year: year,
        posterUrl: posterUrl,
        rating: rating,
        subtitle: subtitle,
        externalIds: externalIds,
        totalPages: totalPages ?? this.totalPages,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        totalSeasons: totalSeasons ?? this.totalSeasons,
        totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      );

  MediaEntry toEntry({required String id, String? title}) => MediaEntry(
        id: id,
        title: title ?? this.title,
        type: type,
        status: MediaStatus.want,
        totalPages: totalPages,
        totalMinutes: totalMinutes,
        totalSeasons: totalSeasons,
        totalEpisodes: totalEpisodes,
        posterUrl: posterUrl,
        year: year,
        externalIds: {...externalIds, source: sourceId},
      );
}
