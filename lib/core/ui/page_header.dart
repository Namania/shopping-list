import 'package:flutter/material.dart';

/// A large page title, with an optional back button, a line under it and
/// actions on the right.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final text = TextTheme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(showBack ? 4 : 20, 8, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack) const BackButton(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: text.headlineMedium!.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: text.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
