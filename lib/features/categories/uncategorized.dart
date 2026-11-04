import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/features/categories/category.dart';

/// The placeholder shown for articles without a category. It has no id and
/// never exists in the database; it is also what the share / backup formats
/// write for those articles.
Category uncategorized(BuildContext context) => Category(
  id: '',
  label: context.l10n.categoriesUncategorized,
  color: Theme.of(context).colorScheme.primary,
);
