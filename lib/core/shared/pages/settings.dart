import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/cubit/setting_default_category_position.dart';
import 'package:shopping_list/core/shared/cubit/setting_enable_calculator.dart';
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
  late bool isCategoryFirst;
  late bool isCalculatorEnabled;

  @override
  void initState() {
    super.initState();
    final AvailableRoute currentState =
        context.read<SettingRouterCubit>().state;
    isArticleRoute = currentState == AvailableRoute.article;
    isCardRoute = currentState == AvailableRoute.card;
    isCategoryFirst = context.read<SettingDefaultCategoryPosition>().getValue();
    isCalculatorEnabled = context.read<SettingEnableCalculator>().isEnabled();
  }

  String getThemeName(String theme, String lang) {
    final Map<String, String> system = {"en": "System", "fr": "Système"};

    final Map<String, String> light = {"en": "Light", "fr": "Clair"};

    final Map<String, String> dark = {"en": "Dark", "fr": "Sombre"};

    switch (theme) {
      case 'system':
        if (system.containsKey(lang)) {
          return system[lang]!;
        }
        return theme;
      case 'light':
        if (light.containsKey(lang)) {
          return light[lang]!;
        }
        return theme;
      case 'dark':
        if (dark.containsKey(lang)) {
          return dark[lang]!;
        }
        return theme;
      default:
        return theme;
    }
  }

  String getLocalName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MenuEntry> themeMenuEntries = UnmodifiableListView<MenuEntry>(
      ThemeMode.values.map<MenuEntry>(
        (ThemeMode mode) => MenuEntry(
          value: mode.name,
          labelWidget: Text(
            getThemeName(mode.name, context.locale.languageCode),
          ),
          label: getThemeName(mode.name, context.locale.languageCode),
        ),
      ),
    );
    String themeMenuEntriesValue = context.read<ThemeCubit>().state.name;

    List<MenuEntry> langMenuEntries = UnmodifiableListView<MenuEntry>(
      context.supportedLocales.map<MenuEntry>(
        (Locale lang) => MenuEntry(
          value: lang.languageCode,
          labelWidget: Text(getLocalName(lang.languageCode)),
          label: getLocalName(lang.languageCode),
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
                  icon: Icons.system_update_rounded,
                  title: context.tr('core.settings.item.version'),
                  trailing: Text("1.3.2"),
                ),
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
                SettingsItem.toggle(
                  context: context,
                  icon: Icons.calculate_rounded,
                  title: context.tr('core.settings.item.calculator'),
                  value: isCalculatorEnabled,
                  onToggle: (value) {
                    context.read<SettingEnableCalculator>().selectValue(
                      value ? AvailableCalculatorState.enable : AvailableCalculatorState.disable,
                    );
                    setState(() {
                      isCalculatorEnabled = value;
                    });
                  },
                ),
                SettingsItem.toggle(
                  context: context,
                  icon: Icons.swap_vert_rounded,
                  title: context.tr('core.settings.item.category'),
                  value: isCategoryFirst,
                  onToggle: (value) {
                    context.read<SettingDefaultCategoryPosition>().selectValue(
                      value ? AvailableState.first : AvailableState.last,
                    );
                    setState(() {
                      isCategoryFirst = value;
                    });
                  },
                ),
              ],
            ),
            SettingsCategory(
              title: context.tr('core.settings.separator.startup'),
              children: [
                SettingsItem.toggle(
                  context: context,
                  icon: Icons.signpost_rounded,
                  title: context.tr('core.settings.item.route.article'),
                  value: isArticleRoute,
                  onToggle: (value) {
                    context.read<SettingRouterCubit>().selectRoute(
                      value ? AvailableRoute.article : AvailableRoute.root,
                    );
                    setState(() {
                      if (value) {
                        isCardRoute = false;
                      }
                      isArticleRoute = value;
                    });
                  },
                ),
                SettingsItem.toggle(
                  context: context,
                  icon: Icons.signpost_rounded,
                  title: context.tr('core.settings.item.route.category'),
                  value: isCardRoute,
                  onToggle: (value) {
                    context.read<SettingRouterCubit>().selectRoute(
                      value ? AvailableRoute.card : AvailableRoute.root,
                    );
                    setState(() {
                      if (value) {
                        isArticleRoute = false;
                      }
                      isCardRoute = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
