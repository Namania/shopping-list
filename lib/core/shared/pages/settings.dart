import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';
import 'package:shopping_list/core/shared/widget/settings_item.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
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
              trailing: IconButton(
                icon: Icon(Icons.contrast_rounded),
                onPressed: () {
                  context.read<ThemeCubit>().toggleThemeMode();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr('core.settings.snack.theme', namedArgs: {"theme": context.read<ThemeCubit>().state.name}),
                          style: TextTheme.of(context).labelLarge,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        duration: Durations.extralong4,
                      ),
                    );
                  }
                },
              ),
            ),
            SettingsItem(
              icon: Icons.language,
              title: context.tr('core.settings.item.lang'),
              trailing: IconButton(
                icon: Icon(Icons.language_rounded),
                onPressed: () {
                  context.setLocale(
                    context.locale.toString() == 'en'
                        ? Locale('fr')
                        : Locale('en'),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr('core.settings.snack.lang', namedArgs: {"lang": context.locale.toString()}),
                          style: TextTheme.of(context).labelLarge,
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        duration: Durations.extralong4,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
