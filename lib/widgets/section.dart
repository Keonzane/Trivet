import 'package:flutter/material.dart';

import '../theme.dart';
import 'caption.dart';

class Section extends StatelessWidget {
  const Section(
      {super.key, required this.title, required this.children, this.trailing});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Caption(title), if (trailing != null) trailing!],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }
}
