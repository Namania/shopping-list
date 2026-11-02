import 'package:flutter/material.dart';

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextTheme.of(context).labelLarge),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      duration: Durations.extralong4,
    ),
  );
}
