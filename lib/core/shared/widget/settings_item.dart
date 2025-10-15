import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
  });

  factory SettingsItem.toggle({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required Function onToggle,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SettingsItem(
      icon: icon,
      title: title,
      trailing: SizedBox(
        width: 70,
        child: FlutterSwitch(
          value: value,
          width: 70,
          height: 36,
          toggleSize: 30,
          borderRadius: 20,
          padding: 3,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.surfaceContainerHighest,
          inactiveSwitchBorder: Border.all(
            color: colorScheme.surfaceContainerHighest,
            width: 2,
          ),
          activeSwitchBorder: Border.all(
            color: colorScheme.primary,
            width: 2,
          ),
          inactiveIcon: Icon(Icons.close_rounded),
          activeIcon: Icon(Icons.check_rounded),
          duration: const Duration(milliseconds: 300),
          onToggle: (val) {
            onToggle(val);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: trailing,
        ),
      ),
    );
  }
}
