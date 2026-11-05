import 'package:flutter/material.dart';

/// A page's content: inside the safe area and, on tablets, centred at a
/// width that stays easy to read instead of stretching across the screen.
class PageBody extends StatelessWidget {
  /// Widest the content gets, in logical pixels.
  static const maxWidth = 720.0;

  final bool bottom;
  final Widget child;

  const PageBody({super.key, this.bottom = true, required this.child});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: bottom,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    ),
  );
}
