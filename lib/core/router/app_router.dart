import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/pages/deep_link_handler.dart';
import 'package:shopping_list/core/shared/pages/home_page.dart';
import 'package:shopping_list/core/shared/pages/loading_page.dart';
import 'package:shopping_list/core/shared/pages/settings.dart';
import 'package:shopping_list/core/utils/custom_json.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/data/models/article_model.dart';
import 'package:shopping_list/features/article/presentation/pages/article_list.dart';
import 'package:shopping_list/features/article/presentation/pages/article_lists.dart';
import 'package:shopping_list/features/calculator/presentation/pages/calculator_list.dart';
import 'package:shopping_list/features/cards/presentation/pages/card_list.dart';
import 'package:shopping_list/features/category/presentation/pages/category_list.dart';

pageBuilder({
  required BuildContext context,
  required GoRouterState state,
  required Widget page,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/loading',
  redirect: (context, state) {
    final uri = state.uri;
    if (uri.scheme == 'shopping-list' &&
        uri.host == 'launch' &&
        state.matchedLocation != '/deeplink') {
      return '/deeplink${uri.hasQuery ? '?${uri.query}' : ''}';
    }
    return null;
  },
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: HomePage()),
    ),
    GoRoute(path: '/loading', builder: (builder, state) => LoadingPage()),
    GoRoute(
      path: '/deeplink',
      builder: (context, state) {
        final uri = state.uri;
        final jsonData = CustomJson.decompressJson(
          uri.queryParameters['data'] ?? '',
        );
        return DeepLinkHandler(jsonData: jsonData);
      },
    ),
    GoRoute(
      path: '/articles',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: ArticleLists()),
    ),
    GoRoute(
      path: '/article',
      pageBuilder:
          (context, state) => pageBuilder(
            context: context,
            state: state,
            page: ArticleList(
              articleList: state.extra as ArticleListModel,
            ),
          ),
    ),
    GoRoute(
      path: '/cards',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: CardList()),
    ),
    GoRoute(
      path: '/categories',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: CategoryList()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: Settings()),
    ),
    GoRoute(
      path: '/calculator',
      pageBuilder:
          (context, state) => pageBuilder(
            context: context,
            state: state,
            page: CalculatorList(
              idList: (state.extra as Map<String, dynamic>)["idList"] as String,
              specificId: (state.extra as Map<String, dynamic>)["specificId"] as bool,
              articles: (state.extra as Map<String, dynamic>)["articles"] as List<ArticleModel>,
            ),
          ),
    ),
  ],
);
