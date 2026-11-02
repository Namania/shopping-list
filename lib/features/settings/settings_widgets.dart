import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:url_launcher/url_launcher.dart';

/// A titled group of settings.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(title, style: TextTheme.of(context).titleLarge),
        ),
        const Divider(indent: 10, endIndent: 10),
        ...children,
      ],
    ),
  );
}

/// One setting: an icon, a title and a trailing control.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  /// A setting opening [url] in the browser.
  SettingsTile.link({super.key, required this.icon, required this.title, required String url})
    : trailing = const Icon(Icons.arrow_right_rounded),
      onTap = (() => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication));

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(leading: Icon(icon), title: Text(title), trailing: trailing),
      ),
    ),
  );
}

/// A boolean setting.
class SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SettingsTile(
      icon: icon,
      title: title,
      trailing: SizedBox(
        width: 70,
        child: FlutterSwitch(
          value: value,
          onToggle: onChanged,
          width: 70,
          height: 36,
          toggleSize: 30,
          borderRadius: 20,
          padding: 3,
          activeColor: colors.primary,
          inactiveColor: colors.surfaceContainerHighest,
          inactiveSwitchBorder: Border.all(color: colors.surfaceContainerHighest, width: 2),
          activeSwitchBorder: Border.all(color: colors.primary, width: 2),
          inactiveIcon: const Icon(Icons.close_rounded),
          activeIcon: const Icon(Icons.check_rounded),
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}

class BuyMeACoffeeTile extends StatelessWidget {
  const BuyMeACoffeeTile({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap:
        () => launchUrl(Uri.parse('https://buymeacoffee.com/namania'), mode: LaunchMode.externalApplication),
    child: Card(
      color: const Color.fromARGB(255, 255, 221, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Image.asset('assets/images/bmac.webp', scale: 5),
            Text(
              'Buy me a coffee',
              style: TextTheme.of(context).titleLarge!.apply(color: Colors.black87, fontFamily: 'Cookie'),
            ),
          ],
        ),
      ),
    ),
  );
}
