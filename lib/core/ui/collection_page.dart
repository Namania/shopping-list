import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/ui/movable_list.dart';
import 'package:shopping_list/core/ui/options_menu.dart';

/// Actions offered in the menu of a [CollectionPage]. [move] is handled by
/// the page itself, the others are forwarded to `onAction`.
enum CollectionAction {
  share(Icons.share_rounded),
  import(Icons.download_rounded),
  move(Icons.shuffle_rounded),
  delete(Icons.delete_rounded);

  final IconData icon;
  const CollectionAction(this.icon);
}

/// The page layout shared by lists, cards and categories: a title, a menu,
/// a reorderable list of tiles, an empty message and an "add" button.
class CollectionPage<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String emptyText;
  final String addLabel;
  final VoidCallback onAdd;
  final List<CollectionAction> actions;
  final ValueChanged<CollectionAction> onAction;
  final String Function(T item) keyOf;
  final Widget Function(BuildContext context, T item, bool movable) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Widgets shown in the app bar before the menu.
  final List<Widget> extraActions;

  const CollectionPage({
    super.key,
    required this.title,
    required this.items,
    required this.emptyText,
    required this.addLabel,
    required this.onAdd,
    required this.actions,
    required this.onAction,
    required this.keyOf,
    required this.itemBuilder,
    required this.onReorder,
    this.extraActions = const [],
  });

  @override
  State<CollectionPage<T>> createState() => _CollectionPageState<T>();
}

class _CollectionPageState<T> extends State<CollectionPage<T>> {
  bool _movable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(onPressed: () => context.go('/')),
        ),
        title: Text(widget.title),
        actions: [
          ...widget.extraActions,
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                _movable
                    ? IconButton(
                      onPressed: () => setState(() => _movable = false),
                      icon: const Icon(Icons.check_rounded),
                    )
                    : OptionsMenu<CollectionAction>(
                      options: [
                        for (final action in widget.actions)
                          MenuOption(action, icon: action.icon, label: context.tr('common.${action.name}')),
                      ],
                      onSelected: (action) {
                        if (action == CollectionAction.move) {
                          setState(() => _movable = true);
                        } else {
                          widget.onAction(action);
                        }
                      },
                    ),
          ),
        ],
      ),
      body:
          widget.items.isEmpty
              ? Center(child: Text(widget.emptyText))
              : MovableList<T>(
                items: widget.items,
                movable: _movable,
                keyOf: widget.keyOf,
                itemBuilder: (context, item) => widget.itemBuilder(context, item, _movable),
                onReorder: widget.onReorder,
              ),
      floatingActionButton: AddButton(label: widget.addLabel, onPressed: widget.onAdd),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// The docked "add" button at the bottom of the collection pages.
class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AddButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: FilledButton.icon(onPressed: onPressed, icon: const Icon(Icons.add_rounded), label: Text(label)),
  );
}
