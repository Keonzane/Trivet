enum WorkoutType { push, pull, legs, run, swim }

class Workout {
  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final DateTime date;
  final String notes;

  const Workout({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.date,
    this.notes = '',
  });

  String get label {
    switch (type) {
      case WorkoutType.push:
        return 'Push day';
      case WorkoutType.pull:
        return 'Pull day';
      case WorkoutType.legs:
        return 'Leg day';
      case WorkoutType.run:
        return 'Run';
      case WorkoutType.swim:
        return 'Swim';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'durationMinutes': durationMinutes,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory Workout.fromMap(Map<String, dynamic> map) => Workout(
        id: map['id'] as String,
        type: WorkoutType.values.byName(map['type'] as String),
        durationMinutes: map['durationMinutes'] as int,
        date: DateTime.parse(map['date'] as String),
        notes: map['notes'] as String? ?? '',
      );
}
