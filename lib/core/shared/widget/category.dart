import 'package:flutter/material.dart';
import 'package:shopping_list/core/shared/widget/settings_item.dart';

class Category extends StatelessWidget {
  final String title;
  final List<SettingsItem> children;

  const Category({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(title, style: TextTheme.of(context).titleLarge),
          ),
          const Divider(indent: 10, endIndent: 10),
          ...children,
        ],
      ),
    );
  }
}
