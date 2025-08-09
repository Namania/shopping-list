import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/core/shared/cubit/setting_router_cubit.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.read<SettingRouterCubit>().getRoute();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(route);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
