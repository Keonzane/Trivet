import 'package:flutter/material.dart';

class Caption extends StatelessWidget {
  const Caption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall
          ?.copyWith(color: theme.colorScheme.secondary),
    );
  }
}
