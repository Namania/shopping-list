import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
