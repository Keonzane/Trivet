import 'package:flutter/material.dart';

import '../theme.dart';
import 'screen_header.dart';

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    required this.loading,
    required this.children,
  });

  final String title;
  final bool loading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: const [ThemeToggleButton()]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: children,
              ),
            ),
    );
  }
}
