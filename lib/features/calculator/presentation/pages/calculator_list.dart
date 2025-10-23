import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  Widget build(BuildContext context) {
    context.read<CalculatorBloc>().add(CalculatorGetAllEvent());
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(context.tr('calculator.title')),
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
          return Column(
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
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  CalculatorModel model = data[index];
                  List<ArticleModel> article =
                      articles.where((a) => a.id == model.idArticle).toList();
                  return CalculatorCard(model: model, article: article.first);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
