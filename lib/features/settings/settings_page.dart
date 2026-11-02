import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shopping_list/core/ui/form_dialog.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/settings/backup.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/settings/settings_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _packageInfo = PackageInfo.fromPlatform();

  static String _languageName(Locale locale) => switch (locale.languageCode) {
    'fr' => 'Français',
    'en' => 'English',
    final code => code,
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SettingsCubit>();
    final settings = cubit.state;

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(context.tr('settings.title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 2,
          children: [
            SettingsSection(
              title: context.tr('settings.sections.general'),
              children: [
                SettingsTile(
                  icon: Icons.system_update_rounded,
                  title: context.tr('settings.items.version'),
                  trailing: FutureBuilder(
                    future: _packageInfo,
                    builder: (context, snapshot) => Text(snapshot.data?.version ?? ''),
                  ),
                ),
                SettingsTile(
                  icon: Icons.contrast_rounded,
                  title: context.tr('settings.items.theme'),
                  trailing: SizedBox(
                    width: 150,
                    child: AppDropdown<ThemeMode>(
                      items: ThemeMode.values,
                      initial: settings.themeMode,
                      labelOf: (mode) => context.tr('settings.themes.${mode.name}'),
                      onSelected: cubit.setThemeMode,
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.language,
                  title: context.tr('settings.items.language'),
                  trailing: SizedBox(
                    width: 150,
                    child: AppDropdown<Locale>(
                      items: context.supportedLocales,
                      initial: context.locale,
                      labelOf: _languageName,
                      onSelected: context.setLocale,
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.cloud_rounded,
                  title: context.tr('settings.items.backup'),
                  trailing: const Icon(Icons.arrow_right_rounded),
                  onTap: () => showBackupSheet(context),
                ),
              ],
            ),
            SettingsSection(
              title: context.tr('settings.sections.article'),
              children: [
                SettingsSwitch(
                  icon: Icons.swap_vert_rounded,
                  title: context.tr('settings.items.uncategorized_first'),
                  value: settings.uncategorizedFirst,
                  onChanged: cubit.setUncategorizedFirst,
                ),
              ],
            ),
            SettingsSection(
              title: context.tr('settings.sections.calculator'),
              children: [
                SettingsSwitch(
                  icon: Icons.calculate_rounded,
                  title: context.tr('settings.items.calculator_enabled'),
                  value: settings.calculatorEnabled,
                  onChanged: (enabled) {
                    cubit.setCalculatorEnabled(enabled);
                    if (!enabled) context.read<PricesCubit>().clear();
                  },
                ),
              ],
            ),
            SettingsSection(
              title: context.tr('settings.sections.startup'),
              children: [
                SettingsTile(
                  icon: Icons.signpost_rounded,
                  title: context.tr('settings.items.start_route'),
                  trailing: SizedBox(
                    width: 150,
                    child: AppDropdown<StartRoute>(
                      items: StartRoute.values,
                      initial: settings.startRoute,
                      labelOf: (route) => context.tr('settings.start.${route.name}'),
                      onSelected: cubit.setStartRoute,
                    ),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: context.tr('settings.sections.developer'),
              children: [
                SettingsTile(
                  icon: Icons.person_rounded,
                  title: context.tr('settings.items.author'),
                  trailing: const Text('Namania'),
                ),
                SettingsTile.link(
                  icon: Icons.language,
                  title: context.tr('settings.items.website'),
                  url: 'https://namania.fr',
                ),
                const BuyMeACoffeeTile(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
