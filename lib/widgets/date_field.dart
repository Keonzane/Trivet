import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// "28 Sep 2026" — the one date format the app uses in entry forms.
String formatShortDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// A read-only text field that opens the date picker when tapped. Owns
/// its own controller so the forms using it don't each need one; the form
/// only holds the [DateTime] and hears about changes through [onChanged].
class DateField extends StatefulWidget {
  const DateField({super.key, required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final TextEditingController _controller =
      TextEditingController(text: formatShortDate(widget.value));

  @override
  void didUpdateWidget(DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = formatShortDate(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value,
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
      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
    );
  }
}
