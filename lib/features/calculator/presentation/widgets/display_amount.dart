import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_list/features/calculator/presentation/bloc/calculator_bloc.dart';

class DisplayAmount extends StatelessWidget {
  const DisplayAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (BuildContext context, CalculatorState state) {
        switch (state) {
          case CalculatorFailure _:
            if (kDebugMode) {
              print(state.message);
            }
            return Text(context.tr('calculator.failure'));
          case CalculatorSuccess _:
            return Text(
              context.tr('calculator.success', args: [state.value.toString()]),
            );
          default:
            return Transform.scale(
              scale: .5,
              child: CircularProgressIndicator()
            );
        }
      },
    );
  }
}
