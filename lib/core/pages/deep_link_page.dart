import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Shown when a `shopping-list://launch?data=…` link cannot be read.
class DeepLinkPage extends StatelessWidget {
  const DeepLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Text(
              context.l10n.deepLinkError,
              style: TextTheme.of(context).titleLarge,
              textAlign: TextAlign.center,
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home_rounded),
              label: Text(context.l10n.deepLinkHome),
            ),
          ],
        ),
      ),
    );
  }
}
