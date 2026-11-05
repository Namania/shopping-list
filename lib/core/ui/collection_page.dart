import 'package:shopping_list/core/ui/page_body.dart';
import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/core/ui/empty_state.dart';
import 'package:shopping_list/core/ui/movable_list.dart';
import 'package:shopping_list/core/ui/options_menu.dart';
import 'package:shopping_list/core/ui/page_header.dart';

/// Actions offered in the menu of a [CollectionPage]. [move] is handled by
/// the page itself, the others are forwarded to `onAction`.
enum CollectionAction {
  share(Icons.ios_share_rounded),
  import(Icons.download_rounded),
  move(Icons.swap_vert_rounded),
  delete(Icons.delete_outline_rounded);

  final IconData icon;
  const CollectionAction(this.icon);

  String label(AppLocalizations l10n) => switch (this) {
    share => l10n.commonShare,
    import => l10n.commonImport,
    move => l10n.commonMove,
    delete => l10n.commonDelete,
  };
}

/// The page layout shared by lists, cards and categories: a large title with
/// its menu, an optional [header] block, the reorderable items, an empty
/// state and an add button in the bottom-right corner.
class CollectionPage<T> extends StatefulWidget {
  final String title;

  /// Small line under the title (totals, counts).
  final String? subtitle;
  final List<T> items;
  final IconData emptyIcon;
  final String emptyText;
  final String addLabel;
  final VoidCallback onAdd;
  final List<CollectionAction> actions;
  final ValueChanged<CollectionAction> onAction;
  final String Function(T item) keyOf;
  final Widget Function(BuildContext context, T item, bool movable) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Shown between the title and the items, scrolling with them.
  final Widget? header;

  /// Widgets shown next to the title, before the menu.
  final List<Widget> extraActions;

  /// A back button, for pages opened above the tabs.
  final bool showBack;

  /// Items can always be reordered: a long press lifts one, a drag moves
  /// it, and the menu's [CollectionAction.move] is left out. Without it,
  /// reordering is a mode entered from the menu.
  final bool reorderOnLongPress;

  const CollectionPage({
    super.key,
    required this.title,
    required this.items,
    required this.emptyIcon,
    required this.emptyText,
    required this.addLabel,
    required this.onAdd,
    required this.actions,
    required this.onAction,
    required this.keyOf,
    required this.itemBuilder,
    required this.onReorder,
    this.subtitle,
    this.header,
    this.extraActions = const [],
    this.showBack = false,
    this.reorderOnLongPress = false,
  });

  @override
  State<CollectionPage<T>> createState() => _CollectionPageState<T>();
}

class _CollectionPageState<T> extends State<CollectionPage<T>> {
  bool _movable = false;

  @override
  Widget build(BuildContext context) {
    final menu = _movable
        ? IconButton.filledTonal(
            tooltip: context.l10n.commonDone,
            onPressed: () => setState(() => _movable = false),
            icon: const Icon(Icons.check_rounded),
          )
        : OptionsMenu<CollectionAction>(
            options: [
              for (final action in widget.actions)
                // A long press already reorders: no need for the mode.
                if (!(widget.reorderOnLongPress && action == CollectionAction.move))
                  MenuOption(action, icon: action.icon, label: action.label(context.l10n)),
            ],
            onSelected: (action) {
              if (action == CollectionAction.move) {
                setState(() => _movable = true);
              } else {
                widget.onAction(action);
              }
            },
          );

    return Scaffold(
      body: PageBody(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              showBack: widget.showBack,
              actions: [...widget.extraActions, menu],
            ),
            Expanded(
              child: widget.items.isEmpty
                  ? ListView(
                      padding: MovableList.padding,
                      children: [
                        if (widget.header != null) widget.header!,
                        EmptyState(icon: widget.emptyIcon, text: widget.emptyText),
                      ],
                    )
                  : MovableList<T>(
                      items: widget.items,
                      movable: _movable || widget.reorderOnLongPress,
                      header: widget.header,
                      keyOf: widget.keyOf,
                      itemBuilder: (context, item) => widget.itemBuilder(context, item, _movable),
                      onReorder: widget.onReorder,
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddButton(label: widget.addLabel, onPressed: widget.onAdd),
    );
  }
}

/// The add button in the bottom-right corner of the collection pages.
class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AddButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    // Every tab keeps its page alive: a shared hero tag would collide.
    heroTag: null,
    onPressed: onPressed,
    icon: const Icon(Icons.add_rounded),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}
