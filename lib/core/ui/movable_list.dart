import 'dart:async';

import 'package:flutter/material.dart';

/// A list whose items can be dragged into a new order when [movable] is on.
/// While dragging near the top or bottom edge, the list scrolls by itself.
class MovableList<T> extends StatefulWidget {
  final List<T> items;
  final bool movable;
  final String Function(T item) keyOf;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Scrolls with the items, above them, and never moves.
  final Widget? header;

  const MovableList({
    super.key,
    required this.items,
    required this.movable,
    required this.keyOf,
    required this.itemBuilder,
    required this.onReorder,
    this.header,
  });

  /// Leaves room under the last item for the add button.
  static const padding = EdgeInsets.fromLTRB(16, 4, 16, 112);

  @override
  State<MovableList<T>> createState() => _MovableListState<T>();
}

class _MovableListState<T> extends State<MovableList<T>> {
  static const _edge = 100.0;
  static const _step = 10.0;

  final _scrollController = ScrollController();
  Timer? _scrollTimer;
  bool _dragging = false;

  /// Local copy so a drop is reflected at once, before the database notifies.
  late List<T> _items = List.of(widget.items);

  @override
  void didUpdateWidget(MovableList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) _items = List.of(widget.items);
  }

  @override
  void dispose() {
    _stopScroll();
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScroll(PointerMoveEvent event) {
    if (!_dragging) return;
    final y = event.position.dy;
    final height = MediaQuery.of(context).size.height;
    if (y < _edge) {
      _startScroll(-_step);
    } else if (y > height - _edge) {
      _startScroll(_step);
    } else {
      _stopScroll();
    }
  }

  void _startScroll(double offset) {
    _scrollTimer ??= Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      _scrollController.animateTo(
        (_scrollController.offset + offset).clamp(position.minScrollExtent, position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  void _stopScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.movable) {
      final header = widget.header;
      final offset = header == null ? 0 : 1;
      return ListView.builder(
        padding: MovableList.padding,
        itemCount: _items.length + offset,
        itemBuilder: (context, index) =>
            index < offset ? header! : widget.itemBuilder(context, _items[index - offset]),
      );
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: _autoScroll,
      onPointerUp: (_) {
        _stopScroll();
        _dragging = false;
      },
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        padding: MovableList.padding,
        header: widget.header,
        proxyDecorator: (child, index, animation) {
          _dragging = true;
          return Material(elevation: 10, color: Colors.transparent, child: child);
        },
        onReorderItem: (oldIndex, newIndex) {
          _dragging = false;
          _stopScroll();
          setState(() => _items.insert(newIndex, _items.removeAt(oldIndex)));
          widget.onReorder(oldIndex, newIndex);
        },
        itemCount: _items.length,
        itemBuilder: (context, index) => KeyedSubtree(
          key: ValueKey(widget.keyOf(_items[index])),
          child: widget.itemBuilder(context, _items[index]),
        ),
      ),
    );
  }
}
