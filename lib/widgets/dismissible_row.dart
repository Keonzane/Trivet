import 'package:flutter/material.dart';

import '../theme.dart';

class DismissibleRow extends StatelessWidget {
  const DismissibleRow({
    super.key,
    required this.itemKey,
    required this.title,
    required this.confirmMessage,
    required this.onDelete,
    required this.child,
  });

  final Key itemKey;
  final String title;
  final String confirmMessage;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(
        context: context,
        title: title,
        message: confirmMessage,
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: child,
    );
  }
}

Future<bool> _confirmDelete({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete "$title"?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
