class WorkLog {
  final String id;
  final String projectId;
  final double hours;
  final DateTime date;

  const WorkLog({
    required this.id,
    required this.projectId,
    required this.hours,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'projectId': projectId,
        'hours': hours,
        'date': date.toIso8601String(),
      };

  factory WorkLog.fromMap(Map<String, dynamic> map) => WorkLog(
        id: map['id'] as String,
        projectId: map['projectId'] as String,
        hours: (map['hours'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
      );
}
