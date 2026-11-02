import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shopping_list/features/sharing/data_importer.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';

/// Imports the payload of a `shopping-list://launch?data=…` link, then shows
/// the page of the imported collection.
class DeepLinkPage extends StatefulWidget {
  final String? data;

  const DeepLinkPage({super.key, required this.data});

  @override
  State<DeepLinkPage> createState() => _DeepLinkPageState();
}

class _DeepLinkPageState extends State<DeepLinkPage> {
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _import());
  }

  Future<void> _import() async {
    final payload = SharePayload.decode(widget.data);
    if (payload == null) {
      setState(() => _error = true);
      return;
    }
    try {
      await context.read<DataImporter>().importShared(payload.kind, payload.items);
    } on TypeError {
      if (mounted) setState(() => _error = true);
      return;
    } on DatabaseException {
      if (mounted) setState(() => _error = true);
      return;
    }
    if (mounted) context.go(payload.kind.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            !_error
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      context.tr('deep_link.error'),
                      style: TextTheme.of(context).titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_rounded),
                      label: Text(context.tr('deep_link.home')),
                    ),
                  ],
                ),
      ),
    );
  }
}
