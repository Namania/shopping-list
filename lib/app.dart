import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shopping_list/core/router/app_router.dart';
import 'package:shopping_list/core/ui/app_snackbar.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/import_sheet.dart';
import 'package:shopping_list/features/sharing/incoming_files.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/features/settings/settings_cubit.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// shadcn hosts the app and resolves light / dark; the `MaterialApp` inside
/// gets the matching Material theme for the Material widgets kept
/// (`Scaffold`, `Dismissible`, `ReorderableListView`, navigation bar).
class App extends StatefulWidget {
  /// The first page; by default the start page chosen in the settings.
  final String? initialLocation;

  const App({super.key, this.initialLocation});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createRouter(
    initialLocation: widget.initialLocation ?? context.read<SettingsCubit>().state.startRoute.path,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => IncomingFiles.listen(_onFile));
    _router.routerDelegate.addListener(_showPendingImport);
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_showPendingImport);
    super.dispose();
  }

  /// A shared link was opened: its page is now set, preview it on top once
  /// drawn.
  void _showPendingImport() {
    final payload = pendingImport.value;
    if (payload == null) return;
    pendingImport.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) importBundle(context, ImportBundle.fromPayload(payload));
    });
  }

  /// A file opened with the app: preview it over the page on screen. The
  /// file that launches the app can arrive before the first page is up: it
  /// then waits for the next frames.
  void _onFile(String content) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      WidgetsBinding.instance
        ..addPostFrameCallback((_) => _onFile(content))
        ..scheduleFrame();
      return;
    }
    final bundle = readImport(content);
    if (bundle == null) {
      showAppSnackBar(context, context.l10n.shareInvalid);
      return;
    }
    importBundle(context, bundle);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    return ShadApp.custom(
      theme: buildShadTheme(settings.ambiance, Brightness.light),
      darkTheme: buildShadTheme(settings.ambiance, Brightness.dark),
      themeMode: settings.themeMode,
      appBuilder: (context) => MaterialApp.router(
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          GlobalShadLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: settings.languageCode == null ? null : Locale(settings.languageCode!),
        localeResolutionCallback: resolveLocale,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(settings.ambiance, Brightness.light),
        darkTheme: buildTheme(settings.ambiance, Brightness.dark),
        themeMode: settings.themeMode,
        routerConfig: _router,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              (Theme.of(context).brightness == Brightness.dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent),
          child: ShadAppBuilder(child: child!),
        ),
      ),
    );
  }
}
