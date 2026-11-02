import 'package:flutter/material.dart';

/// The app's bottom sheet: rounded top, drag handle, padded content that
/// moves up with the keyboard.
Future<T?> showAppBottomSheet<T>(BuildContext context, {required List<Widget> children}) {
  return showModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    backgroundColor: Theme.of(context).colorScheme.surface,
    isScrollControlled: true,
    builder:
        (context) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 4,
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ...children,
            ],
          ),
        ),
  );
}

/// A big tappable tile (icon + label) used to offer a choice in a sheet.
class SheetActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SheetActionTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: colors.primary),
              const SizedBox(height: 8),
              Text(label, style: TextTheme.of(context).labelLarge, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// A muted hint shown under the content of a sheet.
class SheetHint extends StatelessWidget {
  final String text;

  const SheetHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextTheme.of(context).bodySmall?.copyWith(color: Theme.of(context).colorScheme.outlineVariant),
    ),
  );
}
