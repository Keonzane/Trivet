enum MediaType { book, film, series, game }

enum MediaStatus { want, inProgress, done }

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

extension MediaStatusLabel on MediaStatus {
  String get label {
    switch (this) {
      case MediaStatus.want:
        return 'Want to start';
      case MediaStatus.inProgress:
        return 'In progress';
      case MediaStatus.done:
        return 'Done';
    }
  }
}

class MediaEntry {
  final String id;
  final String title;
  final MediaType type;
  final MediaStatus status;
  final int? rating;

  final int durationMinutes;
  final int pages;
  final int season;
  final int episode;

  final String notes;

  const MediaEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.rating,
    this.durationMinutes = 0,
    this.pages = 0,
    this.season = 1,
    this.episode = 1,
    this.notes = '',
  });

  MediaEntry copyWith({
    String? id,
    String? title,
    MediaType? type,
    MediaStatus? status,
    int? rating,
    int? durationMinutes,
    int? pages,
    int? season,
    int? episode,
    String? notes,
  }) {
    return MediaEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pages: pages ?? this.pages,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'status': status.name,
        'rating': rating,
        'durationMinutes': durationMinutes,
        'pages': pages,
        'season': season,
        'episode': episode,
        'notes': notes,
      };

  factory MediaEntry.fromMap(Map<String, dynamic> map) => MediaEntry(
        id: map['id'] as String,
        title: map['title'] as String,
        type: MediaType.values.byName(map['type'] as String),
        status: MediaStatus.values.byName(map['status'] as String),
        rating: map['rating'] as int?,
        durationMinutes: map['durationMinutes'] as int? ?? 0,
        pages: map['pages'] as int? ?? 0,
        season: map['season'] as int? ?? 1,
        episode: map['episode'] as int? ?? 1,
        notes: map['notes'] as String? ?? '',
      );
}
