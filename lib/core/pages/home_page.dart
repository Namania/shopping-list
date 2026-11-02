import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/logo.png', color: Theme.of(context).colorScheme.tertiary),
        title: const Text('Shopping List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              child: Text(context.tr('home.welcome'), style: TextTheme.of(context).displayMedium),
            ),
            const Divider(indent: 10, endIndent: 10),
            const _HomeCard(section: 'lists', route: '/lists', icon: Icons.shopping_bag_rounded),
            const _HomeCard(section: 'categories', route: '/categories', icon: Icons.category),
            const _HomeCard(section: 'cards', route: '/cards', icon: Icons.credit_card_rounded),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String section;
  final String route;
  final IconData icon;

  const _HomeCard({required this.section, required this.route, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              context.tr('$section.title'),
              style: TextTheme.of(context).headlineLarge!.apply(color: colors.primary),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(context.tr('home.$section')), Icon(icon, color: colors.tertiary)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
