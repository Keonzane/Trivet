import 'package:flutter/material.dart';

import '../theme.dart';

class PillarButton extends StatelessWidget {
  const PillarButton({
    super.key,
    required this.pillar,
    required this.label,
    this.onPressed,
  });

  final Pillar pillar;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = context.pillars.of(pillar);
    final onAccent = context.pillars.onPillar;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: onAccent,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}
