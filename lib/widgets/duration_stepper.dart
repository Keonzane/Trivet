import 'package:flutter/material.dart';
import '../theme.dart';
import 'number_stepper.dart';

class DurationStepper extends StatelessWidget {
  const DurationStepper(
      {super.key, required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return Row(
      children: [
        Expanded(
          child: NumberStepper(
            value: hours,
            unit: 'h',
            onChanged: (h) => onChanged(h * 60 + mins),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NumberStepper(
            value: mins,
            unit: 'min',
            min: hours > 0 ? -1 : 0,
            onChanged: (m) => onChanged(hours * 60 + m),
          ),
        ),
      ],
    );
  }
}
