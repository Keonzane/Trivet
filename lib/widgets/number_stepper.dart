import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberStepper extends StatefulWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.unit,
    this.min = 0,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String? unit;
  final int min;

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(NumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((int.tryParse(_controller.text) ?? widget.min) != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _typed(String text) {
    final v = int.tryParse(text);
    if (v != null) widget.onChanged(v < widget.min ? widget.min : v);
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
            visualDensity: VisualDensity.compact,
            onPressed: widget.value > widget.min
                ? () => widget.onChanged(widget.value - 1)
                : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.labelLarge,
              onChanged: _typed,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixText: widget.unit,
                suffixStyle: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            visualDensity: VisualDensity.compact,
            onPressed: () => widget.onChanged(widget.value + 1),
          ),
        ],
      ),
    );
  }
}
