import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/router/app_router.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/theme/text_theme.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createRouter(
    initialLocation: context.read<SettingsCubit>().state.startRoute.path,
  );

  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme(createTextTheme(context, 'Montserrat', 'Montserrat'));
    return MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: context.watch<SettingsCubit>().state.themeMode,
      routerConfig: _router,
    );
  }
}
