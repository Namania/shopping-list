import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:shopping_list/features/category/presentation/bloc/category_bloc.dart';

class DeepLinkHandler extends StatefulWidget {
  final String? jsonData;
  const DeepLinkHandler({super.key, this.jsonData});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  bool error = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.jsonData != null) {
        try {
          final decoded = json.decode(widget.jsonData!);
          executeFunction(decoded);
        } catch (e) {
          setState(() => error = true);
        }
      } else {
        setState(() => error = true);
      }
    });
  }

  void executeFunction(Map<String, dynamic> data) {
    QrCodeActions action = getActionFromString(data['action']);
    String json = jsonEncode(data['json']);

    switch (action) {
      case QrCodeActions.importArticles:
        try {
          context.read<ArticleBloc>().add(
            ArticleImportEvent(
              json: json,
              defaultCategory: CategoryModel(
                label: context.tr('category.default'),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
          context.go('/articles');
        } catch (e) {
          setState(() => error = true);
        }
        break;
      case QrCodeActions.importCategories:
        try {
          context.read<CategoryBloc>().add(CategoryImportEvent(json: json));
          context.go('/categories');
        } catch (e) {
          setState(() => error = true);
        }
        break;
      case QrCodeActions.importCards:
        try {
          context.read<CardBloc>().add(CardImportEvent(json: json));
          context.go('/cards');
        } catch (e) {
          setState(() => error = true);
        }
        break;
      default:
        setState(() => error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            !error
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      context.tr('core.deep_link_error'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.go('/');
                      },
                      label: Text(context.tr('core.deep_link_button')),
                      icon: Icon(Icons.home_rounded),
                    ),
                  ],
                ),
      ),
    );
  }
}

enum QrCodeActions { importArticles, importCategories, importCards, undefined }

QrCodeActions getActionFromString(String actionStr) {
  return QrCodeActions.values.firstWhere(
    (e) => e.name == actionStr,
    orElse: () => QrCodeActions.undefined,
  );
}
