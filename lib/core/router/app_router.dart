import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/pages/app_shell.dart';
import 'package:shopping_list/core/pages/deep_link_page.dart';
import 'package:shopping_list/features/cards/card_page.dart';
import 'package:shopping_list/features/cards/cards_page.dart';
import 'package:shopping_list/features/categories/categories_page.dart';
import 'package:shopping_list/features/lists/list_page.dart';
import 'package:shopping_list/features/lists/lists_page.dart';
import 'package:shopping_list/features/prices/calculator_page.dart';
import 'package:shopping_list/features/settings/settings_page.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

/// The navigator above every page, where sheets opened from outside a page
/// (a link, a file opened with the app) are shown.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// What a shared link brought, waiting for its page to be shown.
final pendingImport = ValueNotifier<SharePayload?>(null);

/// Three tabs (lists, cards, settings) behind a navigation bar; every other
/// page opens full screen above them.
GoRouter createRouter({required String initialLocation}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation,
  redirect: (context, state) {
    final uri = state.uri;
    // A file opened with the app: the activity hands its content over (see
    // IncomingFiles); the page on screen stays.
    if (uri.scheme == 'content' || uri.scheme == 'file') {
      final current = GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration;
      return current == null || current.isEmpty ? initialLocation : current.uri.toString();
    }
    // Development shortcut: shopping-list://launch/<page> opens <page>, so a
    // fresh build can start on the screen being worked on.
    if (kDebugMode && SharePayload.isDeepLink(uri) && uri.path.length > 1 && !SharePayload.hasData(uri)) {
      return uri.path;
    }
    // A shared link: open the page of what it shares; the app previews it
    // there once the page is shown (see pendingImport).
    if (SharePayload.isDeepLink(uri) && state.matchedLocation != '/deeplink') {
      final payload = SharePayload.fromUri(uri);
      if (payload != null) {
        pendingImport.value = payload;
        return payload.kind.route;
      }
      return '/deeplink';
    }
    if (state.matchedLocation == '/') return '/lists';
    return null;
  },
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/lists'),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/lists', builder: (_, _) => const ListsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/cards', builder: (_, _) => const CardsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsPage())],
        ),
      ],
    ),
    _route('/lists/:id', (state) => ListPage(listId: state.pathParameters['id']!)),
    _route('/cards/:id', (state) => CardPage(cardId: state.pathParameters['id']!)),
    _route('/categories', (_) => const CategoriesPage()),
    _route('/calculator', (state) => CalculatorPage(listId: state.uri.queryParameters['list'])),
    GoRoute(path: '/deeplink', builder: (_, _) => const DeepLinkPage()),
  ],
);

/// A full-screen page that slides in from the right.
GoRoute _route(String path, Widget Function(GoRouterState state) page) => GoRoute(
  path: path,
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: page(state),
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: child,
    ),
  ),
);
