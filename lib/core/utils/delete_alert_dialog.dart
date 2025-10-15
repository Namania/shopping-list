import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeleteAlertDialog {
  static dialog(
    BuildContext context,
    String langKey, {
    bool? description,
    bool hasSelection = false,
  }) async {

    final List<Widget> actions = <Widget>[
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(context.tr('$langKey.alert.confirm.action.no')),
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.tr('$langKey.alert.confirm.action.yes')),
        ),
      ),
    ];

    if (hasSelection) {
      actions.insert(
        1,
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('$langKey.alert.confirm.action.selected')),
          ),
        ),
      );
    }

    return await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text(context.tr('$langKey.alert.confirm.title')),
            content: Text(
              context.tr(
                '$langKey.alert.confirm.description${description == null
                    ? ''
                    : description
                    ? '.all'
                    : '.one'}',
              ),
            ),
            actions: actions,
          ),
    );
  }
}
