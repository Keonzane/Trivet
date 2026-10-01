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

  const MediaEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.rating,
  });

  MediaEntry copyWith({
    String? id,
    String? title,
    MediaType? type,
    MediaStatus? status,
    int? rating,
  }) {
    return MediaEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'status': status.name,
        'rating': rating,
      };

  factory MediaEntry.fromMap(Map<String, dynamic> map) => MediaEntry(
        id: map['id'] as String,
        title: map['title'] as String,
        type: MediaType.values.byName(map['type'] as String),
        status: MediaStatus.values.byName(map['status'] as String),
        rating: map['rating'] as int?,
      );
}
