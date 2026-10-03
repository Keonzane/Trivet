import 'package:flutter/material.dart';

import '../services/theme_controller.dart';
import '../theme.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.caption, required this.title});

  final String caption;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                caption,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(title, style: theme.textTheme.headlineLarge),
            ],
          ),
        ),
        const ThemeToggleButton(),
      ],
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ThemeController.instance.toggle(brightness),
    );
  }
}
