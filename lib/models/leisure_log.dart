class LeisureLog {
  final String id;
  final String mediaId;
  final int minutes;
  final DateTime date;

  const LeisureLog({
    required this.id,
    required this.mediaId,
    required this.minutes,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'mediaId': mediaId,
        'minutes': minutes,
        'date': date.toIso8601String(),
      };

  factory LeisureLog.fromMap(Map<String, dynamic> map) => LeisureLog(
        id: map['id'] as String,
        mediaId: map['mediaId'] as String,
        minutes: map['minutes'] as int,
        date: DateTime.parse(map['date'] as String),
      );
}
