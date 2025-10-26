import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/core/shared/widget/custom_bottom_modal.dart';
import 'package:shopping_list/features/calculator/data/models/Calculator_model.dart';
import 'package:shopping_list/features/calculator/presentation/bloc/calculator_bloc.dart';

import '../../../article/data/models/article_model.dart';
import '../../../article/presentation/bloc/article_bloc.dart';
import '../widgets/calculator_card.dart';

class CalculatorList extends StatefulWidget {
  const CalculatorList({super.key});

  @override
  State<CalculatorList> createState() => _CalculatorListState();
}

class _CalculatorListState extends State<CalculatorList> {
  void addToCalculator(BuildContext context, String data) {
    double? value = double.tryParse(data.replaceAll(',', '.'));
    if (value != null) {
      context.read<CalculatorBloc>().add(
        CalculatorAddWithoutArticleEvent(price: value),
      );
    }
  }

  void handleDelete(BuildContext context, int value) {
    switch (value) {
      case 1:
        context.read<CalculatorBloc>().add(CalculatorResetWithEvent());
        break;
      case 0:
        context.read<CalculatorBloc>().add(CalculatorResetWithoutArticleEvent());
        break;
      case -1:
        context.read<CalculatorBloc>().add(CalculatorResetEvent());
        break;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    context.read<CalculatorBloc>().add(CalculatorGetAllEvent());
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(context.tr('calculator.title')),
        actions: [
          Padding(
            padding: const EdgeInsetsGeometry.only(right: 10),
            child: IconButton(
              onPressed: () {
                CustomBottomModal.modal(
                  context,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      child: Text(
                        context.tr('calculator.delete.title'),
                        style: TextTheme.of(context).bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.article_rounded),
                            onPressed: () => handleDelete(context, 1),
                            label: Text(
                              context.tr('calculator.delete.with'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.close),
                            onPressed: () => handleDelete(context, 0),
                            label: Text(
                              context.tr('calculator.delete.without'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              icon: Icon(Icons.delete),
                              onPressed: () => handleDelete(context, -1),
                              label: Text(context.tr('calculator.delete.all')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              icon: Icon(Icons.delete),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CalculatorBloc, CalculatorState>(
        buildWhen: (previous, state) {
          return state is CalculatorSuccess;
        },
        builder: (context, state) {
          final data = context.read<CalculatorBloc>().getAllCalculator();
          final amount = context.read<CalculatorBloc>().getValue();
          final List<ArticleModel> articles =
              context.read<ArticleBloc>().getAllArticle();
          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  context.tr('calculator.empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 10,
                  ),
                  child: Text(
                    "${context.tr('calculator.total')}\n${amount != null ? context.tr('calculator.success', args: [amount.toString()]) : context.tr('calculator.failure')}",
                    textAlign: TextAlign.center,
                    style: TextTheme.of(context).displaySmall!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const Divider(indent: 10, endIndent: 10),
                ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 20,
                    bottom: 60,
                  ),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    CalculatorModel model = data[index];
                    List<ArticleModel> result =
                        articles.where((a) => a.id == model.idArticle).toList();
                    return CalculatorCard(
                      result.isEmpty ? null : result.first,
                      model: model,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          icon: Icon(Icons.add),
          onPressed: () {
            final inputController = TextEditingController();
            CustomBottomModal.calculator(
              context,
              controller: inputController,
              onSubmitted: (data) => {Navigator.pop(context)},
              whenComplete:
                  () => addToCalculator(context, inputController.text),
            );
          },
          label: Text(context.tr('calculator.addButton')),
        ),
      ),
    );
  }
}
