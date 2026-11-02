import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/core/ui/color_dot.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/edit_button.dart';
import 'package:shopping_list/core/ui/swipe_to_delete.dart';
import 'package:shopping_list/core/ui/undo_snackbar.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/categories/category.dart';
import 'package:shopping_list/features/categories/category_form_dialog.dart';

/// A category: tap, pencil or long-press to edit, swipe to delete.
class CategoryTile extends StatelessWidget {
  final Category category;
  final bool movable;

  const CategoryTile({super.key, required this.category, required this.movable});

  Future<void> _edit(BuildContext context) async {
    final input = await showCategoryFormDialog(
      context,
      initial: (label: category.label, color: category.color),
    );
    if (input == null || !context.mounted) return;
    final cubit = context.read<CategoriesCubit>();
    if (cubit.exists(input.label, input.color, exceptId: category.id)) {
      showAppSnackBar(context, context.tr('categories.exists'));
      return;
    }
    await cubit.update(category.copyWith(label: input.label, color: input.color));
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<CategoriesCubit>();
    final deleted = await cubit.remove(category.id);
    if (deleted == null || !context.mounted) return;
    showUndoSnackBar(
      context,
      message: context.tr('common.deleted', args: [category.label]),
      onUndo: () => cubit.restore(deleted),
    );
  }

  @override
  Widget build(BuildContext context) => SwipeToDelete(
    id: category.id,
    confirm: () => confirmDelete(context, message: context.tr('categories.confirm_delete')),
    onDeleted: () => _delete(context),
    child: ListTile(
      onTap: movable ? null : () => _edit(context),
      onLongPress: () => _edit(context),
      leading: movable ? const Icon(Icons.drag_handle_rounded) : ColorDot(category.color),
      title: Text(category.label, style: TextTheme.of(context).bodyLarge),
      trailing: movable ? null : EditButton(onPressed: () => _edit(context)),
    ),
  );
}
