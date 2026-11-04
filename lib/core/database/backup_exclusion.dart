import 'dart:io';

import 'package:flutter/services.dart';

const _channel = MethodChannel('shopping_list/storage');

/// Keeps [directories] out of iCloud backups, so lists and loyalty cards
/// never leave the iPhone. Android needs nothing here: its manifest turns
/// the Google backup off.
Future<void> excludeFromCloudBackup(List<String> directories) async {
  if (!Platform.isIOS) return;
  await _channel.invokeMethod<void>('excludeFromBackup', directories);
}
