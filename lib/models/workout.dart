enum WorkoutType { push, pull, legs, cardio }

class Workout {
  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final DateTime date;
  final String notes;
  final bool done;
  final DateTime? completedAt;

  const Workout({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.date,
    this.notes = '',
    this.done = false,
    this.completedAt,
  });

  Workout toggledDone() => Workout(
        id: id,
        type: type,
        durationMinutes: durationMinutes,
        date: date,
        notes: notes,
        done: !done,
        completedAt: done ? null : DateTime.now(),
      );

  String get label {
    switch (type) {
      case WorkoutType.push:
        return 'Push day';
      case WorkoutType.pull:
        return 'Pull day';
      case WorkoutType.legs:
        return 'Leg day';
      case WorkoutType.cardio:
        return 'Cardio day';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'durationMinutes': durationMinutes,
        'date': date.toIso8601String(),
        'notes': notes,
        'done': done,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'] as String,
        type: WorkoutType.values.byName(map['type'] as String),
        durationMinutes: map['durationMinutes'] as int,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String? ?? '',
        done: map['done'] as bool? ?? true,
        completedAt: map['completedAt'] == null
            ? null
            : DateTime.parse(map['completedAt'] as String),
      );
}
