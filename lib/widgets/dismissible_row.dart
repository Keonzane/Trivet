import 'package:flutter/material.dart';

import '../theme.dart';
import 'confirm_delete.dart';

/// Swipe-right-to-left-to-delete, with a confirmation dialog first. The
/// one place delete lives in this app: there's no delete button on any
/// row or on the media detail screen, only this gesture. That keeps
/// delete out of the way of the tap target every row already has (tap to
/// log more, or to open detail), at the cost of being easy to miss if you
/// don't already know the gesture — a real trade-off, not a shortcut.
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
