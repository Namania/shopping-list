
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/pages/home_page.dart';
import 'package:shopping_list/features/article/presentation/pages/article_list.dart';
import 'package:shopping_list/features/cards/presentation/pages/card_list.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/list', builder: (context, state) => ArticleList()),
    GoRoute(path: '/cards', builder: (context, state) => CardList()),
  ],
);
