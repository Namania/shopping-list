import 'package:flutter/material.dart';
import 'package:shopping_list/features/cards/card_format.dart';

/// A loyalty card drawn as a card: its colour, the store name, the number and
/// the barcode format, with a soft sheen so it reads as a physical card.
class CardFace extends StatelessWidget {
  final String label;
  final String code;
  final Color color;
  final CardFormat format;

  /// Extra line under the number (e.g. the lists it is linked to).
  final String? footer;

  /// Shown on the left of the name (e.g. a drag handle).
  final Widget? leading;

  const CardFace({
    super.key,
    required this.label,
    required this.code,
    required this.color,
    required this.format,
    this.footer,
    this.leading,
  });

  /// Text colour that reads on [color].
  static Color onColor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : const Color(0xDD000000);

  @override
  Widget build(BuildContext context) {
    final ink = onColor(color);
    final soft = ink.withValues(alpha: 0.78);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(color, Colors.white, 0.12)!, color, Color.lerp(color, Colors.black, 0.12)!],
        ),
      ),
      child: Stack(
        children: [
          // A large faint circle in the corner, like a printed card motif.
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 14,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    ?leading,
                    Expanded(
                      child: Text(
                        label.isEmpty ? ' ' : label,
                        style: TextStyle(
                          color: ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ink.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        format.label,
                        style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      code.isEmpty ? '•••• ••••' : _grouped(code),
                      style: TextStyle(
                        color: soft,
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (footer != null) Text(footer!, style: TextStyle(color: soft, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "2501234567890" → "2501 2345 6789 0", easier to read out at a till.
  /// Codes with their own separators ("PDP-0042-7781") stay as they are.
  static String _grouped(String code) {
    if (!RegExp(r'^\d{8,}$').hasMatch(code)) return code;
    final buffer = StringBuffer();
    for (var i = 0; i < code.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(code[i]);
    }
    return buffer.toString();
  }
}
