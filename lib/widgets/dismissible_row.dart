import 'package:flutter/material.dart';

import '../theme.dart';

typedef UndoDelete = Future<void> Function();

const _undoWindow = Duration(seconds: 5);

class DismissibleRow extends StatelessWidget {
  const DismissibleRow({
    super.key,
    required this.itemKey,
    required this.title,
    required this.onDelete,
    required this.child,
  });

  final Key itemKey;
  final String title;
  final Future<UndoDelete> Function() onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      onDismissed: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        final undo = await onDelete();
        messenger.hideCurrentSnackBar();
        final snackBar = messenger.showSnackBar(
          SnackBar(
            content: Text('Deleted "$title"'),
            duration: _undoWindow,
            action: SnackBarAction(label: 'Undo', onPressed: undo),
          ),
        );
        var closed = false;
        snackBar.closed.then((_) => closed = true);
        Future.delayed(_undoWindow, () {
          if (!closed) snackBar.close();
        });
      },
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
