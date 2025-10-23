import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_list/features/calculator/presentation/bloc/calculator_bloc.dart';

class DisplayAmount extends StatelessWidget {
  const DisplayAmount({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CalculatorBloc>().add(CalculatorGetAllEvent());
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      buildWhen: (previous, state) {
        return state is CalculatorSuccess;
      },
      builder: (BuildContext context, CalculatorState state) {
        final amount = context.read<CalculatorBloc>().getValue();
        return TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            shadowColor: WidgetStatePropertyAll(Colors.transparent),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
            elevation: WidgetStatePropertyAll(0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStatePropertyAll(Size.fromRadius(20)),
          ),
          child: Text(
            amount != null
                ? context.tr('calculator.success', args: [amount.toString()])
                : context.tr('calculator.failure'),
            style: TextTheme.of(
              context,
            ).bodyMedium!.apply(color: Theme.of(context).colorScheme.onSurface),
          ),
          onPressed: () {
            context.push<void>("/calculator");
          },
        );
      },
    );
  }
}
