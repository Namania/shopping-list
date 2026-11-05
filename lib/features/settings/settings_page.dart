import 'package:shopping_list/core/ui/page_body.dart';
import 'package:shopping_list/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shopping_list/core/ui/confirm_dialog.dart';
import 'package:shopping_list/core/ui/page_header.dart';
import 'package:shopping_list/features/categories/categories_cubit.dart';
import 'package:shopping_list/features/prices/prices_cubit.dart';
import 'package:shopping_list/features/settings/app_settings.dart';
import 'package:shopping_list/features/backup/backup_sheet.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/features/settings/settings_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _packageInfo = PackageInfo.fromPlatform();

  /// Turning the calculator off erases every amount: ask first when there
  /// are some.
  Future<void> _setCalculator(bool enabled) async {
    final cubit = context.read<SettingsCubit>();
    final prices = context.read<PricesCubit>();
    if (!enabled && prices.state.isNotEmpty) {
      final confirmed = await confirmDelete(
        context,
        message: context.l10n.settingsCalculatorOffConfirm(prices.state.length),
        confirmLabel: context.l10n.settingsCalculatorTurnOff,
      );
      if (!confirmed) return;
      await prices.clear();
    }
    await cubit.setCalculatorEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SettingsCubit>();
    final settings = cubit.state;
    final categoryCount = context.watch<CategoriesCubit>().state.length;
    final l10n = context.l10n;

    return Scaffold(
      body: PageBody(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            PageHeader(title: l10n.settingsTitle),

            SettingsGroup(
              title: l10n.settingsSectionsAppearance,
              children: [
                SettingsChoiceRow<ThemeMode>(
                  icon: Icons.contrast_rounded,
                  title: l10n.settingsItemsTheme,
                  value: settings.themeMode,
                  onChanged: cubit.setThemeMode,
                  options: [
                    (ThemeMode.system, l10n.settingsThemesSystem, Icons.brightness_auto_rounded),
                    (ThemeMode.light, l10n.settingsThemesLight, Icons.light_mode_rounded),
                    (ThemeMode.dark, l10n.settingsThemesDark, Icons.dark_mode_rounded),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsRow(icon: Icons.palette_outlined, title: l10n.settingsItemsAmbiance),
                    AmbiancePicker(
                      value: settings.ambiance,
                      labelOf: (ambiance) => ambiance.label(l10n),
                      onChanged: cubit.setAmbiance,
                    ),
                  ],
                ),
                SettingsChoiceRow<String?>(
                  icon: Icons.translate_rounded,
                  title: l10n.settingsItemsLanguage,
                  value: settings.languageCode,
                  onChanged: cubit.setLanguage,
                  // Language names are written in their own language.
                  options: [
                    (null, l10n.settingsThemesSystem, null),
                    ('fr', 'Français', null),
                    ('en', 'English', null),
                  ],
                ),
              ],
            ),

            SettingsGroup(
              title: l10n.settingsSectionsLists,
              children: [
                SettingsRow.nav(
                  icon: Icons.category_outlined,
                  title: context.l10n.categoriesTitle,
                  subtitle: context.l10n.settingsCategoriesCount(categoryCount),
                  onTap: () => context.push('/categories'),
                ),
                SettingsSwitchRow(
                  icon: Icons.vertical_align_top_rounded,
                  title: l10n.settingsItemsUncategorizedFirst,
                  subtitle: l10n.settingsItemsUncategorizedFirstHint,
                  value: settings.uncategorizedFirst,
                  onChanged: cubit.setUncategorizedFirst,
                ),
                SettingsSwitchRow(
                  icon: Icons.calculate_outlined,
                  title: l10n.settingsItemsCalculatorEnabled,
                  subtitle: l10n.settingsItemsCalculatorHint,
                  value: settings.calculatorEnabled,
                  onChanged: _setCalculator,
                ),
                SettingsChoiceRow<StartRoute>(
                  icon: Icons.rocket_launch_outlined,
                  title: l10n.settingsItemsStartRoute,
                  // "home" is the lists tab since the home page is gone.
                  value: settings.startRoute == StartRoute.cards ? StartRoute.cards : StartRoute.lists,
                  onChanged: cubit.setStartRoute,
                  options: [
                    (StartRoute.lists, l10n.settingsStartLists, Icons.checklist_rounded),
                    (StartRoute.cards, l10n.settingsStartCards, Icons.credit_card_rounded),
                  ],
                ),
              ],
            ),

            SettingsGroup(
              title: l10n.settingsSectionsData,
              children: [
                SettingsRow.nav(
                  icon: Icons.save_outlined,
                  title: l10n.settingsItemsBackup,
                  subtitle: l10n.settingsItemsBackupHint,
                  onTap: () => showBackupSheet(context),
                ),
                SettingsRow.nav(
                  icon: Icons.history_rounded,
                  title: l10n.restorePointsTitle,
                  subtitle: l10n.settingsItemsRestorePointsHint,
                  onTap: () => showRestorePointsSheet(context),
                ),
                SettingsRow.nav(
                  icon: Icons.move_to_inbox_outlined,
                  title: l10n.importTitle,
                  subtitle: l10n.importSubtitle,
                  onTap: () => showImportSheet(context),
                ),
              ],
            ),

            SettingsGroup(
              title: l10n.settingsSectionsAbout,
              children: [
                SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsItemsVersion,
                  trailing: FutureBuilder(
                    future: _packageInfo,
                    builder: (context, snapshot) => Text(
                      snapshot.data?.version ?? '',
                      style: TextTheme.of(
                        context,
                      ).bodyMedium!.copyWith(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ),
                SettingsRow.link(
                  icon: Icons.person_outline_rounded,
                  title: l10n.settingsItemsAuthor,
                  subtitle: 'Namania · namania.fr',
                  url: 'https://namania.fr',
                ),
              ],
            ),

            // The App Store does not allow tipping the developer through an
            // outside link (guideline 3.1.1): the button is Android only.
            if (defaultTargetPlatform != TargetPlatform.iOS) const BuyMeACoffeeButton(),
          ],
        ),
      ),
    );
  }
}
