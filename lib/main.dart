import 'package:easy_localization/easy_localization.dart';
import 'package:shopping_list/core/router/app_router.dart';
import 'package:shopping_list/core/shared/cubit/setting_default_category_position.dart';
import 'package:shopping_list/core/shared/cubit/setting_router_cubit.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/theme/text_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';
import 'package:shopping_list/init_dependencies.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => SettingRouterCubit()),
        BlocProvider(create: (context) => SettingDefaultCategoryPosition()),
        BlocProvider(create: (context) => getIt<ArticleBloc>()),
        BlocProvider(create: (context) => getIt<CardBloc>()),
        BlocProvider(create: (context) => getIt<CategoryBloc>()),
      ],
      child: EasyLocalization(
        supportedLocales: [
          Locale('en'),
          Locale('fr'),
        ],
        saveLocale: true,
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        child: MainApp()
      ),
    ),
  );

  FlutterNativeSplash.remove();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(
      context,
      "Montserrat",
      "Montserrat",
    );
    final MaterialTheme theme = MaterialTheme(textTheme);

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
