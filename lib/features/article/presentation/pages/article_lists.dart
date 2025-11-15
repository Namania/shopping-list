import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/cubit/setting_enable_calculator.dart';
import 'package:shopping_list/core/utils/handle_menu_button.dart';
import 'package:shopping_list/features/article/data/models/article_list_model.dart';
import 'package:shopping_list/features/article/presentation/bloc/article_bloc.dart';
import 'package:shopping_list/features/article/presentation/widgets/article_list_card.dart';
import 'package:shopping_list/features/calculator/presentation/widgets/display_amount.dart';
import 'package:shopping_list/features/category/data/models/category_model.dart';
import 'package:uuid/uuid.dart';

class ArticleLists extends StatefulWidget {
  const ArticleLists({super.key});

  @override
  State<ArticleLists> createState() => _ArticleListsState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _ArticleListsState extends State<ArticleLists> {
  bool movableMode = false;
  bool _isDragging = false;
  List<ArticleListModel> articleLists = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void handleClick(BuildContext context, String value) async {
    HandleMenuButton.click(
      context: context,
      action: value,
      import: (data) {
        context.read<ArticleBloc>().add(
          ArticleImportEvent(
            json: data,
            defaultCategory: CategoryModel(
              label: context.mounted ? context.tr('category.default') : "Other",
              color:
                  context.mounted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black,
            ),
          ),
        );
      },
      onMove: () {
        setState(() {
          movableMode = true;
        });
      },
    );
  }

  void handleAdd(BuildContext context) async {
    final labelController = TextEditingController();
    Uuid uuid = Uuid();

    String? response = await showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(context.tr('articles.alert.add.title')),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'articles.alert.add.placeholder.label',
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text(context.tr('articles.alert.add.action.cancel')),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      labelController.text != ""
                          ? '{"id": "${uuid.v4()}","label": "${labelController.text}", "card": "", "articles": []}'
                          : "",
                    ),
                child: Text(context.tr('article.alert.add.action.add')),
              ),
            ],
          ),
    );

    try {
      if (response != null && response != '') {
        Map<String, dynamic> data =
            json.decode(response) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<ArticleBloc>().add(
            AddListEvent(articleList: ArticleListModel.fromMap(data)),
          );
        }
      }
    } on FormatException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('core.error'),
              style: TextTheme.of(context).labelLarge,
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            duration: Durations.extralong4,
          ),
        );
      }
    }
  }

  void removeArticleList(ArticleListModel articleList) {
    setState(() {
      articleLists.remove(articleList);
    });
  }

  void _startScroll(double offset) {
    _scrollTimer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      if (_scrollController.hasClients) {
        final newOffset = _scrollController.offset + offset;
        _scrollController.animateTo(
          newOffset.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final calculator = context.read<SettingEnableCalculator>().isEnabled();
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(),
        ),
        title: Text(context.tr('core.card.article.title')),
        actions: [
          calculator
              ? DisplayAmount(
                idList: "",
                articles: articleLists.expand((m) => m.articles).toList(),
              )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                movableMode
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          movableMode = false;
                        });
                      },
                      icon: Icon(Icons.check_rounded),
                    )
                    : PopupMenuButton<String>(
                      onSelected: (value) => handleClick(context, value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      itemBuilder: (context) {
                        final choices = [
                          {'label': 'import', 'icon': Icons.download_rounded},
                          {'label': 'move', 'icon': Icons.shuffle_rounded},
                        ];
                        return choices.map((choice) {
                          return PopupMenuItem<String>(
                            padding: EdgeInsets.only(left: 20, right: 10),
                            value: choice['label'] as String,
                            child: Row(
                              children: [
                                Icon(
                                  choice['icon'] as IconData,
                                  size: 20,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  context.tr(
                                    "articles.options.${choice['label']}",
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      icon: const Icon(Icons.more_vert),
                    ),
          ),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (BuildContext context, ArticleState state) {
          if (state is ArticleSuccess) {
            articleLists = state.articles;
          }
          if (articleLists.isEmpty) {
            return Center(child: (Text(context.tr('articles.empty'))));
          }
          return movableMode
              ? Listener(
                behavior: HitTestBehavior.translucent,
                onPointerMove: (event) {
                  if (_isDragging) {
                    final y = event.position.dy;
                    final screenHeight = MediaQuery.of(context).size.height;

                    if (y < 100) {
                      _startScroll(-10);
                    } else if (y > screenHeight - 100) {
                      _startScroll(10);
                    } else {
                      _stopScroll();
                    }
                  }
                },
                onPointerUp: (_) {
                  _stopScroll();
                  _isDragging = false;
                },
                child: ReorderableListView.builder(
                  scrollController: _scrollController,
                  proxyDecorator: (
                    Widget child,
                    int index,
                    Animation<double> animation,
                  ) {
                    _isDragging = true;
                    return Material(
                      elevation: 10,
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    _isDragging = false;
                    _stopScroll();
                    if (newIndex > oldIndex) newIndex -= 1;
                    context.read<ArticleBloc>().add(
                      RerangeArticleEvent(
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                      ),
                    );
                    setState(() {
                      final item = articleLists.removeAt(oldIndex);
                      articleLists.insert(newIndex, item);
                    });
                  },
                  padding: EdgeInsets.only(
                    top: 5,
                    left: 5,
                    right: 5,
                    bottom: 65,
                  ),
                  shrinkWrap: true,
                  itemCount: articleLists.length,
                  itemBuilder: (context, index) {
                    return ArticleListCard(
                      key: ValueKey(articleLists[index].id),
                      articleList: articleLists[index],
                      movableMode: movableMode,
                      removeCategory: removeArticleList,
                    );
                  },
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 65),
                itemCount: articleLists.length,
                itemBuilder: (context, index) {
                  return ArticleListCard(
                    articleList: articleLists[index],
                    movableMode: movableMode,
                    removeCategory: removeArticleList,
                  );
                },
              );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () {
            handleAdd(context);
          },
          label: Text(context.tr('articles.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
