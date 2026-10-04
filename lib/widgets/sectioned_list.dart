import 'package:flutter/material.dart';

import '../theme.dart';

class SectionedList<S> extends StatefulWidget {
  const SectionedList({
    super.key,
    required this.sections,
    required this.labelOf,
    required this.itemsOf,
    required this.initial,
  });

  final List<S> sections;
  final String Function(S section) labelOf;
  final List<Widget> Function(S section) itemsOf;
  final S initial;

  @override
  State<SectionedList<S>> createState() => _SectionedListState<S>();
}

class _SectionedListState<S> extends State<SectionedList<S>> {
  final _controller = ScrollController();
  final _viewportKey = GlobalKey();
  late final Map<S, GlobalKey> _sectionKeys = {
    for (final s in widget.sections) s: GlobalKey(),
  };
  late S _selected = widget.initial;
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_followScroll);
    if (widget.initial != widget.sections.first) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _jumpTo(widget.initial));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _jumpTo(S section) async {
    setState(() => _selected = section);
    final target = _sectionKeys[section]!.currentContext;
    if (target == null) return;
    _jumping = true;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _jumping = false;
  }

  void _followScroll() {
    if (_jumping) return;
    final viewport =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewport == null) return;
    final top = viewport.localToGlobal(Offset.zero).dy;

    var current = widget.sections.first;
    for (final s in widget.sections) {
      final box =
          _sectionKeys[s]!.currentContext?.findRenderObject() as RenderBox?;
      if (box != null &&
          box.localToGlobal(Offset.zero).dy - top <= AppSpacing.md) {
        current = s;
      }
    }
    final position = _controller.position;
    if (position.maxScrollExtent > 0 &&
        position.pixels >= position.maxScrollExtent - 1) {
      current = widget.sections.last;
    }
    if (current != _selected) setState(() => _selected = current);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.labelSmall
        ?.copyWith(color: theme.colorScheme.secondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<S>(
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: [
            for (final s in widget.sections)
              ButtonSegment(value: s, label: Text(widget.labelOf(s))),
          ],
          selected: {_selected},
          onSelectionChanged: (s) => _jumpTo(s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: SingleChildScrollView(
            key: _viewportKey,
            controller: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final s in widget.sections) ...[
                  Padding(
                    key: _sectionKeys[s],
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child:
                        Text(widget.labelOf(s).toUpperCase(), style: caption),
                  ),
                  ..._items(s, theme),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _items(S section, ThemeData theme) {
    final items = widget.itemsOf(section);
    if (items.isEmpty) {
      return [
        Text(
          'Nothing here yet.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.secondary),
        ),
      ];
    }
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.sm),
        items[i],
      ],
    ];
  }
}
