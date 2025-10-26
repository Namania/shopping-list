import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomModal {
  static void modal(BuildContext context, {required List<Widget> children, Function? whenComplete}) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Container(
                  width: 75,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ...children
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (whenComplete != null) {
        whenComplete();
      }
    });
  }

  static void calculator(BuildContext context, {required TextEditingController controller, Function? onSubmitted, Function? whenComplete}) {
    CustomBottomModal.modal(
      context,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: context.tr('calculator.add'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$')),
                ],
                autofocus: true,
                onSubmitted: (data) {
                  if (onSubmitted != null) {
                    onSubmitted(data);
                  }
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  context.tr('calculator.modalMessage'),
                  style: TextTheme.of(context).bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
      whenComplete: () {
        if (whenComplete != null) {
          whenComplete();
        }
      },
    );
  }
}
