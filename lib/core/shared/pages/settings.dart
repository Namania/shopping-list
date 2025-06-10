import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';
import 'package:shopping_list/core/shared/widget/category.dart';
import 'package:shopping_list/core/shared/widget/settings_item.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';

typedef MenuEntry = DropdownMenuEntry<String>;

class Settings extends StatelessWidget {
  const Settings({super.key});

  get state => null;

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
        key: GlobalKey(),
        padding: EdgeInsets.all(10),
        physics: ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 2,
          children: [
            Category(
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
              ],
            ),
            Category(
              title: context.tr('core.settings.separator.article'),
              children: [
                SettingsItem(
                  icon: Icons.share_rounded,
                  title: context.tr('core.settings.item.shareArticle'),
                  trailing: BlocBuilder<ArticleBloc, ArticleState>(
                    builder: (context, state) {
                      switch (state) {
                        case ArticleSuccess _:
                          return IconButton(
                            onPressed: () async {
                              if (state.articles.isNotEmpty) {
                                String data = jsonEncode(
                                  state.articles.map((a) => a.toMap()).toList(),
                                );
                                Directory temp = await getTemporaryDirectory();
                                String path = "${temp.path}/articles.json";
                                File(path).writeAsStringSync(data);

                                if (context.mounted) {
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(path)],
                                      text: context.tr(
                                        'core.settings.shareArticleMessage',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr('article.empty'),
                                      style: TextTheme.of(context).labelLarge,
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                    duration: Durations.extralong4,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.file_download),
                          );
                        default:
                          return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.share_rounded,
                  title: context.tr('core.settings.item.importArticle'),
                  trailing: IconButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowMultiple: false,
                            allowedExtensions: ["json"],
                          );
                      if (context.mounted && result != null) {
                        context.read<ArticleBloc>().add(
                          ArticleImportEvent(
                            json: await result.files.first.xFile.readAsString(),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.file_upload_rounded),
                  ),
                ),
              ],
            ),
            Category(
              title: context.tr('core.settings.separator.card'),
              children: [
                SettingsItem(
                  icon: Icons.share_rounded,
                  title: context.tr('core.settings.item.shareCard'),
                  trailing: BlocBuilder<CardBloc, CardState>(
                    builder: (context, state) {
                      switch (state) {
                        case CardSuccess _:
                          return IconButton(
                            onPressed: () async {
                              if (state.cards.isNotEmpty) {
                                String data = jsonEncode(
                                  state.cards.map((a) => a.toMap()).toList(),
                                );
                                Directory temp = await getTemporaryDirectory();
                                String path = "${temp.path}/cards.json";
                                File(path).writeAsStringSync(data);

                                if (context.mounted) {
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [XFile(path)],
                                      text: context.tr(
                                        'core.settings.shareCardMessage',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr('card.empty'),
                                      style: TextTheme.of(context).labelLarge,
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                    duration: Durations.extralong4,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.file_download),
                          );
                        default:
                          return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                SettingsItem(
                  icon: Icons.share_rounded,
                  title: context.tr('core.settings.item.importCard'),
                  trailing: IconButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowMultiple: false,
                            allowedExtensions: ["json"],
                          );
                      if (context.mounted && result != null) {
                        context.read<CardBloc>().add(
                          CardImportEvent(
                            json: await result.files.first.xFile.readAsString(),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.file_upload_rounded),
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
