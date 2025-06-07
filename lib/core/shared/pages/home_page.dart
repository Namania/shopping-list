import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/cubit/theme_cubit.dart';

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
                context.read<ThemeCubit>().toggleThemeMode();
              },
              icon: Icon(Icons.contrast_rounded)
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
                "Bienvenue !",
                style: TextTheme.of(context).displayMedium
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            CustomCard(
              title: "Ma liste",
              redirect: "/list",
              body: Text("Voir ma liste d'article"),
              icon: Icons.shopping_bag_rounded
            ),
            CustomCard(
              title: "Mes cartes",
              redirect: "/cards",
              body: Text("Voir mes cartes de fidèlité"),
              icon: Icons.credit_card_rounded
            )
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final String redirect;
  final Widget body;
  final IconData icon;

  const CustomCard({super.key, required this.title, required this.redirect, required this.body, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push<void>(redirect);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: TextTheme.of(context).headlineLarge!.apply(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  body,
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
