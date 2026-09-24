enum MediaType { book, film, series, game }

enum MediaStatus { want, inProgress, done }

class MediaEntry {
  final String id;
  final String title;
  final MediaType type;
  final MediaStatus status;
  final int? rating; // 1-5, only meaningful once done

  const MediaEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.rating,
  });

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
