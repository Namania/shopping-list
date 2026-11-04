import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Ready-made colours that read well as category dots and card backgrounds.
const swatchColors = [
  Color(0xFFE53935), // red
  Color(0xFFF4511E), // deep orange
  Color(0xFFFB8C00), // orange
  Color(0xFFF9A825), // amber
  Color(0xFF7CB342), // light green
  Color(0xFF43A047), // green
  Color(0xFF00897B), // teal
  Color(0xFF039BE5), // light blue
  Color(0xFF1E88E5), // blue
  Color(0xFF3949AB), // indigo
  Color(0xFF8E24AA), // purple
  Color(0xFFD81B60), // pink
  Color(0xFF6D4C41), // brown
  Color(0xFF546E7A), // blue grey
];

/// A row of colour swatches, the chosen one ringed, and a last rainbow
/// swatch that opens a fine-grained picker for any other colour.
class ColorSwatchPicker extends StatelessWidget {
  final Color value;
  final ValueChanged<Color> onChanged;

  const ColorSwatchPicker({super.key, required this.value, required this.onChanged});

  static const _size = 40.0;

  bool _same(Color a, Color b) => a.toARGB32() == b.toARGB32();

  Future<void> _pickCustom(BuildContext context) async {
    var picked = value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.colorCustom),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: value,
            onColorChanged: (color) => picked = color,
            hexInputBar: false,
            displayThumbColor: false,
            labelTypes: const [],
            enableAlpha: false,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
            pickerAreaHeightPercent: .6,
            paletteType: PaletteType.hsl,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.commonDone)),
        ],
      ),
    );
    if (confirmed == true) onChanged(picked.withAlpha(255));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final custom = !swatchColors.any((c) => _same(c, value));

    Widget swatch({
      required bool selected,
      required Widget dot,
      required String label,
      required VoidCallback onTap,
    }) => Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _size + 8,
          height: _size + 8,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? colors.onSurface : Colors.transparent, width: 2.5),
          ),
          child: dot,
        ),
      ),
    );

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final color in swatchColors)
          swatch(
            selected: _same(color, value),
            label: '#${color.toARGB32().toRadixString(16).substring(2)}',
            onTap: () => onChanged(color),
            dot: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        swatch(
          selected: custom,
          label: context.l10n.colorCustom,
          onTap: () => _pickCustom(context),
          dot: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: custom ? value : null,
              gradient: custom
                  ? null
                  : const SweepGradient(
                      colors: [
                        Color(0xFFE53935),
                        Color(0xFFF9A825),
                        Color(0xFF43A047),
                        Color(0xFF1E88E5),
                        Color(0xFF8E24AA),
                        Color(0xFFE53935),
                      ],
                    ),
            ),
            child: Icon(Icons.colorize_rounded, size: 18, color: custom ? _onColor(value) : Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Black or white, whichever reads better on [color].
Color _onColor(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black87;
