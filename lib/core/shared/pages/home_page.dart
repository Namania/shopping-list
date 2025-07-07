import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/widget/custom_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/logo.png", color: Theme.of(context).colorScheme.tertiary,),
        title: Text("Shopping List"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                context.push<void>("/settings");
              },
              icon: Icon(Icons.settings)
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 50
              ),
              child: Text(
                context.tr('core.welcome'),
                style: TextTheme.of(context).displayMedium
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            CustomCard(
              title: context.tr('core.card.article.title'),
              redirect: "/articles",
              body: Text(context.tr('core.card.article.description')),
              icon: Icons.shopping_bag_rounded
            ),
            CustomCard(
              title: context.tr('core.card.category.title'),
              redirect: "/categories",
              body: Text(context.tr('core.card.category.description')),
              icon: Icons.category
            ),
            CustomCard(
              title: context.tr('core.card.card.title'),
              redirect: "/cards",
              body: Text(context.tr('core.card.card.description')),
              icon: Icons.credit_card_rounded
            ),
          ],
        ),
      ),
    );
  }
}
