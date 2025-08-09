import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shopping_list/core/shared/cubit/setting_router_cubit.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';
import 'package:shopping_list/core/shared/widget/settings_category.dart';
import 'package:shopping_list/core/shared/widget/settings_item.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late bool isArticleRoute;
  late bool isCardRoute;

  @override
  void initState() {
    super.initState();
    final AvailableRoute currentState = context.read<SettingRouterCubit>().state;
    isArticleRoute =
        currentState == AvailableRoute.article;
    isCardRoute =
        currentState == AvailableRoute.card;
  }

  @override
  Widget build(BuildContext context) {
    List<MenuEntry> themeMenuEntries = UnmodifiableListView<MenuEntry>(
      ThemeMode.values.map<MenuEntry>(
        (ThemeMode mode) => MenuEntry(
          value: mode.name,
          labelWidget: Text(mode.name),
          label: mode.name,
        ),
      ),
    );
    String themeMenuEntriesValue = context.read<ThemeCubit>().state.name;

    List<MenuEntry> langMenuEntries = UnmodifiableListView<MenuEntry>(
      context.supportedLocales.map<MenuEntry>(
        (Locale lang) => MenuEntry(
          value: lang.languageCode,
          labelWidget: Text(lang.languageCode),
          label: lang.languageCode,
        ),
      ),
    );
    String langMenuEntriesValue = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(context.tr('core.settings.title')),
      ),
      body: SingleChildScrollView(
        key: GlobalKey(),
        padding: EdgeInsets.all(10),
        physics: ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 2,
          children: [
            SettingsCategory(
              title: context.tr('core.settings.separator.main'),
              children: [
                SettingsItem(
                  icon: Icons.contrast_rounded,
                  title: context.tr('core.settings.item.theme'),
                  trailing: DropdownMenu<String>(
                    initialSelection: themeMenuEntriesValue,
                    onSelected: (String? value) {
                      ThemeMode newThemeMode;
                      switch (value) {
                        case "light":
                          newThemeMode = ThemeMode.light;
                          break;
                        case "dark":
                          newThemeMode = ThemeMode.dark;
                          break;
                        default:
                          newThemeMode = ThemeMode.system;
                          break;
                      }
                      context.read<ThemeCubit>().selectThemeMode(newThemeMode);
                    },
                    dropdownMenuEntries: themeMenuEntries,
                    selectedTrailingIcon: Icon(Icons.arrow_drop_up_rounded),
                    trailingIcon: Icon(Icons.arrow_drop_down_rounded),
                  ),
                ),
                SettingsItem(
                  icon: Icons.language,
                  title: context.tr('core.settings.item.lang'),
                  trailing: DropdownMenu<String>(
                    initialSelection: langMenuEntriesValue,
                    onSelected: (String? value) {
                      if (value != null &&
                          context.supportedLocales.contains(Locale(value))) {
                        context.setLocale(Locale(value));
                      }
                    },
                    dropdownMenuEntries: langMenuEntries,
                    selectedTrailingIcon: Icon(Icons.arrow_drop_up_rounded),
                    trailingIcon: Icon(Icons.arrow_drop_down_rounded),
                  ),
                ),
                SettingsItem(
                  icon: Icons.signpost_rounded,
                  title: context.tr('core.settings.item.route.article'),
                  trailing: SizedBox(
                    width: 70,
                    child: FlutterSwitch(
                      value: isArticleRoute,
                      width: 70,
                      height: 36,
                      toggleSize: 30,
                      borderRadius: 20,
                      padding: 3,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      inactiveSwitchBorder: Border.all(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        width: 2,
                      ),
                      activeSwitchBorder: Border.all(
                        width: 2,
                      ),
                      inactiveIcon: Icon(Icons.close_rounded),
                      activeIcon: Icon(Icons.check_rounded),
                      duration: const Duration(milliseconds: 300),
                      onToggle: (val) {
                        context.read<SettingRouterCubit>().selectRoute(
                          val ? AvailableRoute.article : AvailableRoute.root,
                        );
                        setState(() {
                          if (val) {
                            isCardRoute = false;
                          }
                          isArticleRoute = val;
                        });
                      },
                    ),
                  ),
                ),
                SettingsItem(
                  icon: Icons.signpost_rounded,
                  title: context.tr('core.settings.item.route.category'),
                  trailing: SizedBox(
                    width: 70,
                    child: FlutterSwitch(
                      value: isCardRoute,
                      width: 70,
                      height: 36,
                      toggleSize: 30,
                      borderRadius: 20,
                      padding: 3,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      inactiveSwitchBorder: Border.all(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        width: 2,
                      ),
                      activeSwitchBorder: Border.all(
                        width: 2,
                      ),
                      inactiveIcon: Icon(Icons.close_rounded),
                      activeIcon: Icon(Icons.check_rounded),
                      duration: const Duration(milliseconds: 300),
                      onToggle: (val) {
                        context.read<SettingRouterCubit>().selectRoute(
                          val ? AvailableRoute.card : AvailableRoute.root,
                        );
                        setState(() {
                          if (val) {
                            isArticleRoute = false;
                          }
                          isCardRoute = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
