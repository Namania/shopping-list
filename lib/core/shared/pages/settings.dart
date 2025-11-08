import 'dart:collection';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/cubit/setting_default_category_position.dart';
import 'package:shopping_list/core/shared/cubit/setting_enable_calculator.dart';
import 'package:shopping_list/core/shared/cubit/setting_router_cubit.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';
import 'package:shopping_list/core/shared/widget/buy_me_a_coffee.dart';
import 'package:shopping_list/core/shared/widget/custom_bottom_modal.dart';
import 'package:shopping_list/core/shared/widget/settings_category.dart';
import 'package:shopping_list/core/shared/widget/settings_item.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // ignore: non_constant_identifier_names
  final String VERSION = "1.3.5";

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

  void openBrowser(String url) async {
    if (url != "") {
      Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          kDebugMode) {
        print("Can't open url");
      }
    }
  }

  void handleBackup(BuildContext context) {
    context.read<ArticleBloc>().add(ArticleGetAllEvent());
    context.read<CardBloc>().add(CardGetAllEvent());
    context.read<CategoryBloc>().add(CategoryGetAllEvent());
    CustomBottomModal.modal(
      context,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  DateTime now = DateTime.now();

                  List<ArticleModel> articles = context.read<ArticleBloc>().getAllArticle();
                  List<CardModel> cards = context.read<CardBloc>().getAllCard();
                  List<CategoryModel> categories = context.read<CategoryBloc>().getAllCategory();

                  String data = jsonEncode({"articles": articles, "cards": cards, "categories": categories});
                  String? file = await FilePicker.platform.saveFile(
                    fileName: 'shopping-list_${now.toIso8601String()}.json',
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                    bytes: Uint8List.fromList(utf8.encode(data)),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr('core.settings.snack.backup.download.${file == null ? 'success' : 'failure'}'),
                          style: TextTheme.of(context).labelLarge,
                        ),
                        backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                        duration: Durations.extralong4,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_download_rounded,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('core.settings.backup.download'),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  bool imported = false;
                  FilePickerResult? response = await FilePicker.platform
                    .pickFiles(
                      type: FileType.custom,
                      allowMultiple: false,
                      allowedExtensions: ["json"],
                    );
                  if (response != null) {
                    String result = await response.files.first.xFile.readAsString();
                    Map<String, dynamic> data = jsonDecode(result);
                    if (context.mounted) {
                      context.read<ArticleBloc>().add(
                        ArticleImportEvent(
                          json: jsonEncode(data["articles"]),
                          defaultCategory: CategoryModel(
                            label: context.mounted ? context.tr('category.default') : "Other",
                            color:
                                context.mounted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.black,
                          ),
                        ),
                      );
                      context.read<CardBloc>().add(
                        CardImportEvent(
                          json: jsonEncode(data["cards"]),
                        ),
                      );
                      context.read<CategoryBloc>().add(
                        CategoryImportEvent(
                          json: jsonEncode(data["categories"]),
                        ),
                      );
                      imported = true;
                      Navigator.pop(context);
                    }
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr('core.settings.snack.backup.download.${imported ? 'success' : 'failure'}'),
                          style: TextTheme.of(context).labelLarge,
                        ),
                        backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainer,
                        duration: Durations.extralong4,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('core.settings.backup.upload'),
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
                  title: context.tr('core.settings.item.main.version'),
                  trailing: Text(VERSION),
                ),
                SettingsItem(
                  icon: Icons.contrast_rounded,
                  title: context.tr('core.settings.item.main.theme'),
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
                  title: context.tr('core.settings.item.main.lang'),
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
                  onTap: () => handleBackup(context),
                  icon: Icons.cloud_rounded,
                  title: context.tr('core.settings.item.main.backup'),
                  trailing: Icon(Icons.arrow_right_rounded),
                ),
              ],
            ),
            SettingsCategory(
              title: context.tr('core.settings.separator.article'),
              children: [
                SettingsItem.toggle(
                  context: context,
                  icon: Icons.swap_vert_rounded,
                  title: context.tr('core.settings.item.article.category'),
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
              title: context.tr('core.settings.separator.calculator'),
              children: [
                SettingsItem.toggle(
                  context: context,
                  icon: Icons.calculate_rounded,
                  title: context.tr('core.settings.item.calculator.enable'),
                  value: isCalculatorEnabled,
                  onToggle: (value) {
                    context.read<SettingEnableCalculator>().selectValue(
                      value
                          ? AvailableCalculatorState.enable
                          : AvailableCalculatorState.disable,
                    );
                    if (!context.read<SettingEnableCalculator>().isEnabled()) {
                      context.read<CalculatorBloc>().add(
                        CalculatorResetEvent(),
                      );
                    }
                    setState(() {
                      isCalculatorEnabled = value;
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
            SettingsCategory(
              title: context.tr('core.settings.separator.developer'),
              children: [
                SettingsItem(
                  icon: Icons.person_rounded,
                  title: context.tr('core.settings.item.developer.author'),
                  trailing: Text("Namania"),
                ),
                SettingsItem(
                  onTap: () => openBrowser('https://namania.fr'),
                  icon: Icons.language,
                  title: context.tr('core.settings.item.developer.website'),
                  trailing: Icon(Icons.arrow_right_rounded),
                ),
                BuyMeACoffee(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
