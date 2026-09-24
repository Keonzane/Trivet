import 'package:flutter/material.dart';

import '../theme.dart';

class EntryModal extends StatelessWidget {
  const EntryModal({
    super.key,
    required this.pillar,
    required this.title,
    required this.fields,
    required this.onSave,
    required this.onCancel,
  });

  final Pillar pillar;
  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Text(title, style: theme.textTheme.headlineSmall)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onCancel,
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final field in fields) ...[
            field,
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: onCancel, child: const Text('Cancel')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child:
                    FilledButton(onPressed: onSave, child: const Text('Save')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LabelledField extends StatelessWidget {
  const LabelledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.secondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
