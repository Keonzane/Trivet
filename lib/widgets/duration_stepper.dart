import 'package:flutter/material.dart';
import '../theme.dart';
import 'number_stepper.dart';

class DurationStepper extends StatelessWidget {
  const DurationStepper({
    super.key,
    required this.minutes,
    required this.onChanged,
    this.max,
  });

  final int minutes;
  final ValueChanged<int> onChanged;
  final int? max;

  void _set(int total) {
    final limit = max;
    onChanged(limit != null && total > limit ? limit : total);
  }

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
            max: max == null ? null : max! ~/ 60,
            onChanged: (h) => _set(h * 60 + mins),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NumberStepper(
            value: mins,
            unit: 'min',
            min: hours > 0 ? -1 : 0,
            max: max != null && hours >= max! ~/ 60 ? max! % 60 : null,
            onChanged: (m) => _set(hours * 60 + m),
          ),
        ),
      ],
    );
  }
}
