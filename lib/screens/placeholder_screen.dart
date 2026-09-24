import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/empty_state.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.note});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: theme.textTheme.headlineLarge),
              Expanded(
                child: EmptyState(
                  message: note,
                  icon: Icons.construction_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
