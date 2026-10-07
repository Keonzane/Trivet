enum MediaType { book, film, series, game }

enum MediaStatus { want, inProgress, done }

extension MediaStatusLabel on MediaStatus {
  String get label => switch (this) {
        MediaStatus.want => 'Want',
        MediaStatus.inProgress => 'In progress',
        MediaStatus.done => 'Done',
      };
}

extension MediaTypeLabel on MediaType {
  String get label {
    switch (this) {
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
}

class MediaEntry {
  final String id;
  final String title;
  final MediaType type;
  final MediaStatus status;
  final int? rating; // 1-5, only meaningful once done

  final int durationMinutes; // time spent: books and games
  final int totalPages;
  final int currentPage;
  final int totalMinutes; // runtime: films and series
  final int stoppedMinutes; // where you stopped: films and series
  final int totalSeasons;
  final int currentSeason;
  final int totalEpisodes;
  final int currentEpisode;

  final String notes;
  final String review;
  final DateTime? completedAt;

  const MediaEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.rating,
    this.durationMinutes = 0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.totalMinutes = 0,
    this.stoppedMinutes = 0,
    this.totalSeasons = 1,
    this.currentSeason = 1,
    this.totalEpisodes = 1,
    this.currentEpisode = 1,
    this.notes = '',
    this.review = '',
    this.completedAt,
  });

  int get trackedMinutes => type == MediaType.film || type == MediaType.series
      ? stoppedMinutes
      : durationMinutes;

  MediaEntry withTrackedMinutes(int minutes) =>
      type == MediaType.film || type == MediaType.series
          ? copyWith(stoppedMinutes: minutes)
          : copyWith(durationMinutes: minutes);

  MediaEntry copyWith({
    MediaStatus? status,
    int? rating,
    int? durationMinutes,
    int? totalPages,
    int? currentPage,
    int? totalMinutes,
    int? stoppedMinutes,
    int? totalSeasons,
    int? currentSeason,
    int? totalEpisodes,
    int? currentEpisode,
    String? notes,
    String? review,
  }) {
    final newStatus = status ?? this.status;
    return MediaEntry(
      id: id,
      title: title,
      type: type,
      status: newStatus,
      rating: rating ?? this.rating,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      stoppedMinutes: stoppedMinutes ?? this.stoppedMinutes,
      totalSeasons: totalSeasons ?? this.totalSeasons,
      currentSeason: currentSeason ?? this.currentSeason,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      notes: notes ?? this.notes,
      review: review ?? this.review,
      completedAt: newStatus != MediaStatus.done
          ? null
          : this.status == MediaStatus.done
              ? completedAt
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'status': status.name,
        'rating': rating,
        'durationMinutes': durationMinutes,
        'totalPages': totalPages,
        'currentPage': currentPage,
        'totalMinutes': totalMinutes,
        'stoppedMinutes': stoppedMinutes,
        'totalSeasons': totalSeasons,
        'currentSeason': currentSeason,
        'totalEpisodes': totalEpisodes,
        'currentEpisode': currentEpisode,
        'notes': notes,
        'review': review,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MediaEntry.fromMap(Map<String, dynamic> map) => MediaEntry(
        id: map['id'] as String,
        title: map['title'] as String,
        type: MediaType.values.byName(map['type'] as String),
        status: MediaStatus.values.byName(map['status'] as String),
        rating: map['rating'] as int?,
        durationMinutes: map['durationMinutes'] as int? ?? 0,
        totalPages: map['totalPages'] as int? ?? 0,
        currentPage: map['currentPage'] as int? ?? 0,
        totalMinutes: map['totalMinutes'] as int? ?? 0,
        stoppedMinutes: map['stoppedMinutes'] as int? ?? 0,
        totalSeasons: map['totalSeasons'] as int? ?? 1,
        currentSeason: map['currentSeason'] as int? ?? 1,
        totalEpisodes: map['totalEpisodes'] as int? ?? 1,
        currentEpisode: map['currentEpisode'] as int? ?? 1,
        notes: map['notes'] as String? ?? '',
        review: map['review'] as String? ?? '',
        completedAt: map['completedAt'] == null
            ? null
            : DateTime.parse(map['completedAt'] as String),
      );
}
