import 'package:flutter/material.dart';

/// The app's bottom sheet: rounded top, drag handle, padded content that
/// moves up with the keyboard.
Future<T?> showAppBottomSheet<T>(BuildContext context, {required List<Widget> children}) {
  return showModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    backgroundColor: Theme.of(context).colorScheme.surface,
    isScrollControlled: true,
    builder: (context) => Padding(
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

/// A sheet offering a few ways to do something, each with a line saying
/// what it is for.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<SheetOption> options,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => OptionSheetBody(title: title, subtitle: subtitle, options: options),
  );
}

/// The content of [showOptionSheet], also used by sheets that swap it for
/// another view.
class OptionSheetBody extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<SheetOption> options;

  const OptionSheetBody({super.key, required this.title, this.subtitle, required this.options});

  @override
  Widget build(BuildContext context) {
    final text = TextTheme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(title, style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  subtitle!,
                  style: text.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            const SizedBox(height: 4),
            ...options,
          ],
        ),
      ),
    );
  }
}

/// One way to do something in an option sheet.
class SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// `null` greys the option out; [subtitle] should then say why.
  final VoidCallback? onTap;

  const SheetOption({super.key, required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = TextTheme.of(context);
    final enabled = onTap != null;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Row(
              spacing: 14,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.primary),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(title, style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w600)),
                      Text(subtitle, style: text.bodySmall!.copyWith(color: colors.outline)),
                    ],
                  ),
                ),
                if (enabled) Icon(Icons.chevron_right_rounded, color: colors.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
