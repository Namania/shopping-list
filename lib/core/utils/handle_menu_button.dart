import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/core/utils/custom_json.dart';
import 'package:shopping_list/core/utils/handle_scaning.dart';

class HandleMenuButton {
  static void click({
    required BuildContext context,
    required String action,
    List<dynamic>? data,
    String? deepLinkAction,
    Function? import,
    Function? onDelete,
    Function? onMove,
  }) async {
    switch (action) {
      case 'share':
        if (data == null || deepLinkAction == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr('core.error'),
                style: TextTheme.of(context).labelLarge,
              ),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              duration: Durations.extralong4,
            ),
          );
          return;
        }
        final rawJson = {
          "action": deepLinkAction,
          "json": data.map((a) => a.toMap()).toList(),
        };

        final encodedData = Uri.encodeComponent(
          CustomJson.compressJson(jsonEncode(rawJson)),
        );
        final deepLink = 'shopping-list://launch?data=$encodedData';
        final qrCode = PrettyQrView.data(
          data: deepLink,
          decoration: const PrettyQrDecoration(
            shape: PrettyQrSmoothSymbol(color: Colors.black, roundFactor: 0.0),
            quietZone: PrettyQrQuietZone.pixels(20),
            background: Colors.white,
          ),
        );

        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(20),
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
                  SizedBox(height: 250, width: 250, child: qrCode),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () async {
                      if (data.isNotEmpty) {
                        String json = jsonEncode(
                          data.map((a) => a.toMap()).toList(),
                        );
                        Directory temp = await getTemporaryDirectory();
                        String path = "${temp.path}/articles.json";
                        File(path).writeAsStringSync(json);

                        if (context.mounted) {
                          await SharePlus.instance.share(
                            ShareParams(
                              files: [XFile(path)],
                              text: context.tr(
                                'core.settings.shareArticleMessage',
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.tr('article.empty'),
                              style: TextTheme.of(context).labelLarge,
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainer,
                            duration: Durations.extralong4,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.insert_drive_file_rounded),
                    label: Text(context.tr('modal.send_file')),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('modal.export'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
        break;
      case 'import':
        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            String res = await HandleScaning.scan(
                              context,
                              ScanMode.QR,
                            );
                            Uri? uri = Uri.tryParse(res);
                            if (res != "" &&
                                uri != null &&
                                context.mounted &&
                                import != null) {
                              final decoded = json.decode(
                                CustomJson.decompressJson(
                                  uri.queryParameters['data'] ?? '',
                                ),
                              );
                              import(jsonEncode(decoded['json']));
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr('modal.scan'),
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                  type: FileType.custom,
                                  allowMultiple: false,
                                  allowedExtensions: ["json"],
                                );
                            if (context.mounted &&
                                result != null &&
                                import != null) {
                              import(
                                await result.files.first.xFile.readAsString(),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.insert_drive_file_rounded,
                                  size: 36,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.tr('modal.pick_file'),
                                  style: Theme.of(context).textTheme.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
        break;
      case 'delete':
        if (onDelete != null) {
          onDelete();
        }
        break;
      case 'move':
        if (onMove != null) {
          onMove();
        }
        break;
    }
  }
}
