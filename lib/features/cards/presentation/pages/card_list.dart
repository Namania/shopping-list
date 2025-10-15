import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopping_list/features/cards/data/models/card_model.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_bloc.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_event.dart';
import 'package:shopping_list/features/cards/presentation/bloc/cards_state.dart';
import 'package:shopping_list/features/cards/presentation/widgets/custom_card.dart';

import '../../../../core/shared/utils.dart';

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  bool movableMode = false;
  bool _isDragging = false;
  List<CardModel> cards = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> handleScaning(BuildContext context, ScanMode mode) async {
    String barcodeScanRes = '';
    try {
      String res = await FlutterBarcodeScanner.scanBarcode(
        "#ffffff",
        context.tr('card.cancel'),
        false,
        mode,
      );
      if (res != "-1") {
        barcodeScanRes = res;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du scan");
      }
    }
    return barcodeScanRes;
  }

  void handleClick(BuildContext context, String value) async {
    switch (value) {
      case 'share':
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                  BlocBuilder<CardBloc, CardState>(
                    builder: (BuildContext context, CardState state) {
                      switch (state) {
                        case CardFailure _:
                          if (kDebugMode) print(state.message);
                          return Text(
                            context.tr('core.error'),
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        case CardSuccess _:
                          final rawJson = {
                            "action": "importCards",
                            "json": state.cards.map((a) => a.toMap()).toList(),
                          };

                          final encodedData = Uri.encodeComponent(
                            Utils.compressJson(jsonEncode(rawJson)),
                          );
                          final deepLink =
                              'shopping-list://launch?data=$encodedData';

                          return Column(
                            children: [
                              SizedBox(
                                height: 250,
                                width: 250,
                                child: PrettyQrView.data(
                                  data: deepLink,
                                  decoration: const PrettyQrDecoration(
                                    shape: PrettyQrSmoothSymbol(
                                      color: Colors.black,
                                      roundFactor: 0.0,
                                    ),
                                    quietZone: PrettyQrQuietZone.pixels(20),
                                    background: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () async {
                                  if (state.cards.isNotEmpty) {
                                    String data = jsonEncode(
                                      state.cards
                                          .map((a) => a.toMap())
                                          .toList(),
                                    );
                                    Directory temp =
                                        await getTemporaryDirectory();
                                    String path = "${temp.path}/cards.json";
                                    File(path).writeAsStringSync(data);

                                    if (context.mounted) {
                                      await SharePlus.instance.share(
                                        ShareParams(
                                          files: [XFile(path)],
                                          text: context.tr(
                                            'core.settings.shareCardMessage',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.tr('card.empty'),
                                          style:
                                              TextTheme.of(context).labelLarge,
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainer,
                                        duration: Durations.extralong4,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.insert_drive_file_rounded,
                                ),
                                label: Text(context.tr('modal.send_file')),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  textStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ],
                          );
                        default:
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('modal.export'),
                    style: TextTheme.of(context).bodySmall!.apply(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                            String res = await handleScaning(
                              context,
                              ScanMode.QR,
                            );
                            Uri? uri = Uri.tryParse(res);
                            if (res != "" && uri != null && context.mounted) {
                              final decoded = json.decode(
                                Utils.decompressJson(
                                  uri.queryParameters['data'] ?? '',
                                ),
                              );

                              context.read<CardBloc>().add(
                                CardImportEvent(
                                  json: jsonEncode(decoded['json']),
                                ),
                              );
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
                            if (context.mounted && result != null) {
                              context.read<CardBloc>().add(
                                CardImportEvent(
                                  json:
                                      await result.files.first.xFile
                                          .readAsString(),
                                ),
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
      case 'move':
        setState(() {
          movableMode = true;
        });
        break;
    }
  }

  String capitalize(String string) {
    return string.isNotEmpty
        ? "${string[0].toUpperCase()}${string.substring(1).toLowerCase()}"
        : string;
  }

  void removeCard(CardModel card) {
    setState(() {
      cards.remove(card);
    });
  }

  void _startScroll(double offset) {
    _scrollTimer ??= Timer.periodic(Duration(milliseconds: 50), (_) {
      if (_scrollController.hasClients) {
        final newOffset = _scrollController.offset + offset;
        _scrollController.animateTo(
          newOffset.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          ),
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(
            onPressed: () {
              context.go("/");
            },
          ),
        ),
        title: Text(context.tr('core.card.card.title')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:
                movableMode
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          movableMode = false;
                        });
                      },
                      icon: Icon(Icons.check_rounded),
                    )
                    : PopupMenuButton<String>(
                      onSelected: (value) => handleClick(context, value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      icon: const Icon(Icons.more_vert),
                      tooltip: context.tr("card.options.tooltip"),
                      itemBuilder: (context) {
                        final choices = [
                          {'label': 'share', 'icon': Icons.share_rounded},
                          {'label': 'import', 'icon': Icons.download_rounded},
                          {'label': 'move', 'icon': Icons.shuffle_rounded},
                        ];

                        return choices.map((choice) {
                          return PopupMenuItem<String>(
                            padding: EdgeInsets.only(left: 20, right: 10),
                            value: choice['label'] as String,
                            child: Row(
                              children: [
                                Icon(
                                  choice['icon'] as IconData,
                                  size: 20,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  context.tr("card.options.${choice['label']}"),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
          ),
        ],
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (BuildContext context, CardState state) {
          if (state is CardSuccess) {
            cards = state.cards;
          }
          if (cards.isEmpty) {
            return Center(child: (Text(context.tr('card.empty'))));
          }
          return movableMode
              ? Listener(
                behavior: HitTestBehavior.translucent,
                onPointerMove: (event) {
                  if (_isDragging) {
                    final y = event.position.dy;
                    final screenHeight = MediaQuery.of(context).size.height;

                    if (y < 100) {
                      _startScroll(-10);
                    } else if (y > screenHeight - 100) {
                      _startScroll(10);
                    } else {
                      _stopScroll();
                    }
                  }
                },
                onPointerUp: (_) {
                  _stopScroll();
                  _isDragging = false;
                },
                child: ReorderableListView.builder(
                  scrollController: _scrollController,
                  proxyDecorator: (
                    Widget child,
                    int index,
                    Animation<double> animation,
                  ) {
                    _isDragging = true;
                    return Material(
                      elevation: 10,
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    _isDragging = false;
                    _stopScroll();
                    if (newIndex > oldIndex) newIndex -= 1;
                    context.read<CardBloc>().add(
                      RerangeCardEvent(oldIndex: oldIndex, newIndex: newIndex),
                    );
                    setState(() {
                      final item = cards.removeAt(oldIndex);
                      cards.insert(newIndex, item);
                    });
                  },
                  padding: EdgeInsets.only(
                    top: 5,
                    left: 5,
                    right: 5,
                    bottom: 65,
                  ),
                  shrinkWrap: true,
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return CustomCard(
                      key: ValueKey(
                        "${cards[index].label}${cards[index].code}${cards[index].color.toHexString()}",
                      ),
                      card: cards[index],
                      movableMode: movableMode,
                      removeCard: removeCard,
                    );
                  },
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 65),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return CustomCard(
                    card: cards[index],
                    movableMode: movableMode,
                    removeCard: removeCard,
                  );
                },
              );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FilledButton.icon(
          onPressed: () async {
            final labelController = TextEditingController();
            final codeController = TextEditingController();

            Color pickerColor = Theme.of(context).colorScheme.primary;

            void changeColor(Color color) {
              setState(() => pickerColor = color);
            }

            String? response = await showDialog<String>(
              context: context,
              builder:
                  (BuildContext context) => AlertDialog(
                    title: Text(context.tr('card.alert.add.title')),
                    content: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            TextField(
                              controller: labelController,
                              decoration: InputDecoration(
                                hintText: context.tr(
                                  'card.alert.add.placeholder.name',
                                ),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                            TextField(
                              controller: codeController,
                              decoration: InputDecoration(
                                hintText: context.tr(
                                  'card.alert.add.placeholder.code',
                                ),
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    String res = await handleScaning(
                                      context,
                                      ScanMode.BARCODE,
                                    );
                                    if (res.isNotEmpty) {
                                      codeController.text = res;
                                    }
                                  },
                                  icon: Icon(Icons.camera_alt_rounded),
                                ),
                              ),
                              keyboardType: TextInputType.streetAddress,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ColorPicker(
                                hexInputBar: false,
                                pickerColor: pickerColor,
                                onColorChanged: changeColor,
                                displayThumbColor: false,
                                labelTypes: [],
                                enableAlpha: false,
                                pickerAreaBorderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                                pickerAreaHeightPercent: .5,
                                paletteType: PaletteType.hsl,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: Text(context.tr('card.alert.add.action.cancel')),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pop(
                              context,
                              labelController.text.isNotEmpty &&
                                      codeController.text.isNotEmpty
                                  ? '{"label": "${capitalize(labelController.text)}", "code": "${codeController.text}", "color": ${pickerColor.toARGB32()}}'
                                  : "",
                            ),
                        child: Text(context.tr('card.alert.add.action.add')),
                      ),
                    ],
                  ),
            );

            try {
              if (response != null && response != '') {
                Map<String, dynamic> data =
                    json.decode(response) as Map<String, dynamic>;
                if (context.mounted) {
                  context.read<CardBloc>().add(
                    AddCardEvent(card: CardModel.fromMap(data)),
                  );
                }
              }
            } on FormatException {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr('core.error'),
                      style: TextTheme.of(context).labelLarge,
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    duration: Durations.extralong4,
                  ),
                );
              }
            }
          },
          label: Text(context.tr('card.add')),
          icon: Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
