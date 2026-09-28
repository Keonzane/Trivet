import 'package:flutter/material.dart';

import '../theme.dart';

class DurationStepper extends StatelessWidget {
  const DurationStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.step,
    required this.unit,
    this.min = 0,
  });

  final num value;
  final ValueChanged<num> onChanged;
  final num step;
  final String unit;
  final num min;

  String get _display {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} $unit';
    }
    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value - step >= min
                ? () => onChanged(value - step)
                : null,
          ),
          Expanded(
            child: Center(
              child: Text(_display, style: theme.textTheme.labelLarge),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onChanged(value + step),
          ),
        ],
      ),
    );
  }
}
