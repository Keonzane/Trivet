enum ProjectStatus { active, paused, done }

class Project {
  final String id;
  final String title;
  final String subtitle;
  final ProjectStatus status;
  final String notes;

  const Project({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    this.notes = '',
  });

  Project copyWith({
    String? id,
    String? title,
    String? subtitle,
    ProjectStatus? status,
    String? notes,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'status': status.name,
        'notes': notes,
      };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String? ?? '',
        status: ProjectStatus.values.byName(map['status'] as String),
        notes: map['notes'] as String? ?? '',
      );
}
