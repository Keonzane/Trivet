import 'package:flutter/material.dart';

import 'app_text_field.dart';

const monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatShortDate(DateTime d) =>
    '${d.day} ${monthNames[d.month - 1]} ${d.year}';

class DateField extends StatefulWidget {
  const DateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onClear,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback? onClear;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final TextEditingController _controller =
      TextEditingController(text: _text);

  String get _text =>
      widget.value == null ? 'None' : formatShortDate(widget.value!);

  @override
  void didUpdateWidget(DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _controller.text = _text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hint: 'Date',
      controller: _controller,
      onTap: _pick,
      suffixIcon: widget.onClear != null && widget.value != null
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Clear',
              onPressed: widget.onClear,
            )
          : const Icon(Icons.calendar_today_outlined, size: 18),
    );
  }
}
