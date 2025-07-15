import 'package:flutter/material.dart';

class StoreLogo extends StatelessWidget {
  final String label;
  final double size;

  const StoreLogo({super.key, required this.label, this.size = 32});

  String getImageName() {
    String name = "";
    List<String> words = label.split(' ');
    List<String> availableLogo = [
      "leclerc",
      "carrefour",
      "super u",
      "auchan",
      "lidl",
      "monoprix",
    ];
    for (String word in words) {
      if (availableLogo.contains(word.toLowerCase()) ||
          availableLogo.contains(
            "$word ${words[(words.indexOf(word) + 1) % words.length]}"
                .toLowerCase(),
          )) {
        name =
            availableLogo.contains(word.toLowerCase())
                ? word.toLowerCase()
                : "$word ${words[(words.indexOf(word) + 1) % words.length]}"
                    .toLowerCase();
      }
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      radius: 25,
      child: Image.asset(
        'assets/logos/${getImageName()}.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => (Text(
              label.substring(0, 1),
              style: TextTheme.of(context).bodyLarge!.apply(
                fontWeightDelta: 300,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            )),
      ),
    );
  }
}
