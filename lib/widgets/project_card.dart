import 'package:flutter/material.dart';

import '../models/project.dart';
import '../theme.dart';
import 'date_field.dart';
import 'pillar_card.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.hoursThisWeek,
    required this.onTap,
  });

  final Project project;
  final double hoursThisWeek;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final due = project.dueDate;
    return PillarCard(
      pillar: Pillar.work,
      title: project.title,
      subtitle: due == null ? 'Due: None' : 'Due: ${formatShortDate(due)}',
      trailing: Text(
        '${hoursThisWeek.toStringAsFixed(1)} h',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      onTap: onTap,
    );
  }
}
