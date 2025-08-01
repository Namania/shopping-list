import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/pages/home_page.dart';
import 'package:shopping_list/core/shared/pages/settings.dart';
import 'package:shopping_list/features/article/presentation/pages/article_list.dart';
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
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: HomePage()),
    ),
    GoRoute(
      path: '/articles',
      pageBuilder:
          (context, state) =>
              pageBuilder(context: context, state: state, page: ArticleList()),
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
  ],
);
