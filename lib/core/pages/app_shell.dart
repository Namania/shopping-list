import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The three tabs of the app: a navigation bar at the bottom on phones, a
/// rail on the side on tablets, where the screen is wide enough.
class AppShell extends StatelessWidget {
  /// Width from which the tabs move to a side rail.
  static const railFrom = 600.0;

  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final divider = BorderSide(color: Theme.of(context).colorScheme.outlineVariant);
    final tabs = [
      (Icons.checklist_rounded, l10n.navLists),
      (Icons.credit_card_rounded, l10n.navCards),
      (Icons.tune_rounded, l10n.navSettings),
    ];

    if (MediaQuery.sizeOf(context).width >= railFrom) {
      return Scaffold(
        body: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(border: Border(right: divider)),
              child: SafeArea(
                right: false,
                child: NavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: _go,
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: 0,
                  destinations: [
                    for (final (icon, label) in tabs)
                      NavigationRailDestination(icon: Icon(icon), label: Text(label)),
                  ],
                ),
              ),
            ),
            Expanded(child: shell),
          ],
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: divider)),
        child: NavigationBar(
          height: 68,
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final (icon, label) in tabs) NavigationDestination(icon: Icon(icon), label: label),
          ],
        ),
      ),
    );
  }
}
