enum ProjectStatus { active, paused, done }

class Project {
  final String id;
  final String title;
  final String subtitle; // e.g. "Client work", "Coursework"
  final ProjectStatus status;

  const Project({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  Project copyWith({
    String? id,
    String? title,
    String? subtitle,
    ProjectStatus? status,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'status': status.name,
      };

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String? ?? '',
        status: ProjectStatus.values.byName(map['status'] as String),
      );
}
