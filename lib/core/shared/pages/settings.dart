import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';
import 'package:shopping_list/core/shared/widget/settings_item.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class Settings extends StatelessWidget {
  const Settings({super.key});

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
        title: Text(context.tr('core.card.settings.title')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        physics: ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 2,
          children: <SettingsItem>[
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
          ],
        ),
      ),
    );
  }
}
