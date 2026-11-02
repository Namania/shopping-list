import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/pages/deep_link_page.dart';
import 'package:shopping_list/core/pages/home_page.dart';
import 'package:shopping_list/features/cards/cards_page.dart';
import 'package:shopping_list/features/categories/categories_page.dart';
import 'package:shopping_list/features/lists/list_page.dart';
import 'package:shopping_list/features/lists/lists_page.dart';
import 'package:shopping_list/features/prices/calculator_page.dart';
import 'package:shopping_list/features/settings/settings_page.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

GoRouter createRouter({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  redirect: (context, state) {
    final uri = state.uri;
    if (SharePayload.isDeepLink(uri) && state.matchedLocation != '/deeplink') {
      return Uri(path: '/deeplink', queryParameters: uri.queryParameters).toString();
    }
    return null;
  },
  routes: [
    _route('/', (_) => const HomePage()),
    _route('/lists', (_) => const ListsPage()),
    _route('/lists/:id', (state) => ListPage(listId: state.pathParameters['id']!)),
    _route('/cards', (_) => const CardsPage()),
    _route('/categories', (_) => const CategoriesPage()),
    _route('/settings', (_) => const SettingsPage()),
    _route('/calculator', (state) => CalculatorPage(listId: state.uri.queryParameters['list'])),
    GoRoute(
      path: '/deeplink',
      builder: (context, state) => DeepLinkPage(data: state.uri.queryParameters['data']),
    ),
  ],
);

/// A route whose page slides in from the right.
GoRoute _route(String path, Widget Function(GoRouterState state) page) => GoRoute(
  path: path,
  pageBuilder:
      (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: page(state),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) => SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.ease)),
              ),
              child: child,
            ),
      ),
);
