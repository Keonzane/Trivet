import 'package:flutter/material.dart';

import '../theme.dart';
import 'confirm_delete.dart';

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
      confirmDismiss: (_) => confirmDelete(
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
