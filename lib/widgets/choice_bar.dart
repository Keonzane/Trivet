import 'package:flutter/material.dart';

class ChoiceBar<T> extends StatelessWidget {
  const ChoiceBar({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final current = selected;
    return SegmentedButton<T>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      emptySelectionAllowed: current == null,
      segments: [
        for (final v in values)
          ButtonSegment(value: v, label: Text(labelOf(v))),
      ],
      selected: current == null ? {} : {current},
      onSelectionChanged: (s) {
        if (s.isNotEmpty) onSelected(s.first);
      },
    );
  }
}
