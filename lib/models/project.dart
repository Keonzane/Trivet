enum ProjectStatus { active, paused, done }

extension ProjectStatusLabel on ProjectStatus {
  String get label => switch (this) {
        ProjectStatus.active => 'Active',
        ProjectStatus.paused => 'Paused',
        ProjectStatus.done => 'Done',
      };
}

class Project {
  final String id;
  final String title;
  final ProjectStatus status;
  final String notes;
  final DateTime? dueDate;

  const Project({
    required this.id,
    required this.title,
    required this.status,
    this.notes = '',
    this.dueDate,
  });

  Project copyWith({
    String? id,
    String? title,
    ProjectStatus? status,
    String? notes,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      dueDate: dueDate,
    );
  }

  Project withDueDate(DateTime? dueDate) => Project(
        id: id,
        title: title,
        status: status,
        notes: notes,
        dueDate: dueDate,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'status': status.name,
        'notes': notes,
        'dueDate': dueDate?.toIso8601String(),
      };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as String,
        title: map['title'] as String,
        status: ProjectStatus.values.byName(map['status'] as String),
        notes: map['notes'] as String? ?? '',
        dueDate: map['dueDate'] == null
            ? null
            : DateTime.parse(map['dueDate'] as String),
      );
}
