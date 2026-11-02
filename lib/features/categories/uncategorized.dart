import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/features/categories/category.dart';

/// The placeholder shown for articles without a category. It has no id and
/// never exists in the database; it is also what the share / backup formats
/// write for those articles.
Category uncategorized(BuildContext context) => Category(
  id: '',
  label: context.tr('categories.uncategorized'),
  color: Theme.of(context).colorScheme.primary,
);
