import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The three tabs of the app and their navigation bar.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: NavigationBar(
          height: 68,
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) =>
              shell.goBranch(index, initialLocation: index == shell.currentIndex),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.checklist_rounded), label: context.l10n.navLists),
            NavigationDestination(icon: const Icon(Icons.credit_card_rounded), label: context.l10n.navCards),
            NavigationDestination(icon: const Icon(Icons.tune_rounded), label: context.l10n.navSettings),
          ],
        ),
      ),
    );
  }
}
