import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.errorText,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
  });

  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final String? errorText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: onTap != null,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
