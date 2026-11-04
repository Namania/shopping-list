import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/core/ui/app_bottom_sheet.dart';
import 'package:shopping_list/features/sharing/import_bundle.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:shopping_list/l10n/l10n.dart';

/// Largest deep link a QR code can hold (version 40, low error correction,
/// byte mode), with some margin.
const _maxQrBytes = 2900;

/// Offers every way to share [payload]: as readable [text] when given (lists),
/// as a QR code to scan face to face, or as a file to open with the app.
/// [what] names what is shared ("3 lists").
Future<void> showShareSheet(
  BuildContext context,
  SharePayload payload, {
  required String what,
  String? text,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _ShareSheet(payload: payload, what: what, text: text),
  );
}

class _ShareSheet extends StatefulWidget {
  final SharePayload payload;
  final String what;
  final String? text;

  const _ShareSheet({required this.payload, required this.what, this.text});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  late final _link = widget.payload.toDeepLink();
  late final _fitsQr = utf8.encode(_link).length <= _maxQrBytes;
  bool _showQr = false;

  Future<void> _shareText() async {
    Navigator.pop(context);
    await SharePlus.instance.share(ShareParams(text: widget.text));
  }

  Future<void> _shareFile() async {
    final l10n = context.l10n;
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/shopping-list-${widget.payload.kind.name}.json');
    await file.writeAsString(TransferFile.share(widget.payload));
    if (!mounted) return;
    Navigator.pop(context);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        text: switch (widget.payload.kind) {
          ShareKind.lists => l10n.shareMessageLists,
          ShareKind.categories => l10n.shareMessageCategories,
          ShareKind.cards => l10n.shareMessageCards,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_showQr) return _QrView(link: _link, onBack: () => setState(() => _showQr = false));
    return OptionSheetBody(
      title: l10n.shareTitle,
      subtitle: widget.what,
      options: [
        if (widget.text != null)
          SheetOption(
            icon: Icons.notes_rounded,
            title: l10n.shareText,
            subtitle: l10n.shareTextHint,
            onTap: _shareText,
          ),
        SheetOption(
          icon: Icons.qr_code_2_rounded,
          title: l10n.shareQr,
          subtitle: _fitsQr ? l10n.shareQrHint : l10n.shareTooBig,
          onTap: _fitsQr ? () => setState(() => _showQr = true) : null,
        ),
        SheetOption(
          icon: Icons.insert_drive_file_outlined,
          title: l10n.shareFile,
          subtitle: l10n.shareFileHint,
          onTap: _shareFile,
        ),
      ],
    );
  }
}

/// The QR code, large, on white and with the screen at full brightness so
/// any camera reads it.
class _QrView extends StatefulWidget {
  final String link;
  final VoidCallback onBack;

  const _QrView({required this.link, required this.onBack});

  @override
  State<_QrView> createState() => _QrViewState();
}

class _QrViewState extends State<_QrView> {
  @override
  void initState() {
    super.initState();
    ScreenBrightness.instance.setApplicationScreenBrightness(1).ignore();
  }

  @override
  void dispose() {
    ScreenBrightness.instance.resetApplicationScreenBrightness().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(l10n.shareQrScanHint, textAlign: TextAlign.center, style: TextTheme.of(context).bodyLarge),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PrettyQrView.data(
                    data: widget.link,
                    decoration: const PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(color: Colors.black, roundFactor: 0),
                      quietZone: PrettyQrQuietZone.pixels(20),
                      background: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.shareOtherWays),
            ),
          ],
        ),
      ),
    );
  }
}
