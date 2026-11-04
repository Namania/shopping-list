import 'package:flutter/material.dart';
import 'package:shopping_list/core/theme/palette.dart';
import 'package:url_launcher/url_launcher.dart';

/// A titled group of settings: a small label, then the rows in one rounded
/// card separated by hairlines.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextTheme.of(
                context,
              ).labelLarge!.copyWith(color: colors.outline, fontWeight: FontWeight.w600),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(indent: 64),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The icon of a setting, on a soft tinted square.
class SettingsIcon extends StatelessWidget {
  final IconData icon;

  const SettingsIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 20, color: colors.primary),
    );
  }
}

/// One setting row: icon, title, an optional line of explanation, and
/// what sits on the right (a value, a switch, a chevron).
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// A row that opens [url] in the browser.
  SettingsRow.link({super.key, required this.icon, required this.title, this.subtitle, required String url})
    : trailing = const _Chevron(icon: Icons.open_in_new_rounded),
      onTap = (() => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication));

  /// A row that leads somewhere else.
  const SettingsRow.nav({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  }) : trailing = const _Chevron();

  @override
  Widget build(BuildContext context) {
    final text = TextTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            spacing: 14,
            children: [
              SettingsIcon(icon),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(title, style: text.bodyLarge!.copyWith(fontWeight: FontWeight.w500)),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: text.bodySmall!.copyWith(color: Theme.of(context).colorScheme.outline),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  final IconData icon;

  const _Chevron({this.icon = Icons.chevron_right_rounded});

  @override
  Widget build(BuildContext context) => Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline);
}

/// A boolean setting; tapping anywhere on the row flips it.
class SettingsSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SettingsRow(
    icon: icon,
    title: title,
    subtitle: subtitle,
    onTap: () => onChanged(!value),
    trailing: Switch(value: value, onChanged: onChanged),
  );
}

/// A setting with a few choices, shown as one segmented control under its
/// title so every option is visible and one tap away.
///
/// The control never cuts a label: it shows icons and labels when they fit
/// on one line, drops the icons when that is tight, and stacks the options
/// when even the labels do not fit (small screen, large font).
class SettingsChoiceRow<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<(T, String, IconData?)> options;
  final T value;
  final ValueChanged<T> onChanged;

  const SettingsChoiceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// Horizontal room a segment takes besides its label: padding and border.
  static const _segmentChrome = 2 * 12.0 + 2;

  /// Room an icon takes in a segment, with its gap to the label.
  static const _iconRoom = 18.0 + 8;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final labelStyle =
        Theme.of(context).segmentedButtonTheme.style?.textStyle?.resolve({}) ??
        TextTheme.of(context).labelLarge!;
    final widest = options
        .map((o) {
          final painter = TextPainter(
            text: TextSpan(text: o.$2, style: TextTheme.of(context).labelLarge!.merge(labelStyle)),
            textScaler: scaler,
            textDirection: Directionality.of(context),
            maxLines: 1,
          )..layout();
          return painter.width;
        })
        .reduce((a, b) => a > b ? a : b);
    final hasIcons = options.any((o) => o.$3 != null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 14,
            children: [
              SettingsIcon(icon),
              Expanded(
                child: Text(
                  title,
                  style: TextTheme.of(context).bodyLarge!.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Segments share the width equally, so the widest label decides.
              final perSegment = constraints.maxWidth / options.length;
              final fitsWithIcons = widest + _segmentChrome + (hasIcons ? _iconRoom : 0) <= perSegment;
              final fitsInline = widest + _segmentChrome <= perSegment;
              final showIcons = hasIcons && (fitsWithIcons || !fitsInline);
              return SegmentedButton<T>(
                direction: fitsInline ? Axis.horizontal : Axis.vertical,
                showSelectedIcon: false,
                segments: [
                  for (final (option, label, optionIcon) in options)
                    ButtonSegment(
                      value: option,
                      label: Text(label),
                      icon: showIcons && optionIcon != null ? Icon(optionIcon, size: 18) : null,
                    ),
                ],
                selected: {value},
                onSelectionChanged: (selection) => onChanged(selection.first),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Every ambiance drawn with its own colours, so the choice is made by
/// sight. As many columns as the names fit in at the current width and
/// font size; a name is never cut.
class AmbiancePicker extends StatelessWidget {
  final Ambiance value;
  final String Function(Ambiance) labelOf;
  final ValueChanged<Ambiance> onChanged;

  const AmbiancePicker({super.key, required this.value, required this.labelOf, required this.onChanged});

  static const _gap = 10.0;

  /// Room a preview needs around its name: padding and border.
  static const _chrome = 2 * (8 + 2.5);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scaler = MediaQuery.textScalerOf(context);
    final labels = {for (final a in Ambiance.values) a: labelOf(a)};
    final widest = labels.values
        .map((label) {
          final painter = TextPainter(
            text: TextSpan(text: label, style: _AmbiancePreview.labelStyle),
            textScaler: scaler,
            textDirection: Directionality.of(context),
            maxLines: 1,
          )..layout();
          return painter.width;
        })
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final needed = widest + _chrome + 4;
          final columns = ((constraints.maxWidth + _gap) / (needed + _gap)).floor().clamp(1, 3);
          final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final ambiance in Ambiance.values)
                SizedBox(
                  width: width,
                  child: _AmbiancePreview(
                    palette: Palette.of(ambiance, brightness),
                    label: labels[ambiance]!,
                    selected: ambiance == value,
                    onTap: () => onChanged(ambiance),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AmbiancePreview extends StatelessWidget {
  final Palette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AmbiancePreview({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const labelStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 13);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final p = palette;
    Widget bar(double? width, Color color) => Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: p.ground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              // A miniature list card: title, progress, accent button.
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(p.radius / 2),
                ),
                child: Row(
                  spacing: 6,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          bar(30, p.ink),
                          Stack(children: [bar(null, p.line), bar(22, p.done)]),
                        ],
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(p.radius / 2),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: labelStyle.copyWith(color: p.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The yellow "Buy me a coffee" button, in the service's own colours.
class BuyMeACoffeeButton extends StatelessWidget {
  const BuyMeACoffeeButton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
    child: Material(
      color: const Color(0xFFFFDD00),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            launchUrl(Uri.parse('https://buymeacoffee.com/namania'), mode: LaunchMode.externalApplication),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Image.asset('assets/images/bmac.webp', height: 28),
              const Text(
                'Buy me a coffee',
                style: TextStyle(color: Colors.black87, fontFamily: 'Cookie', fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
