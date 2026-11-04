import 'dart:io';

import 'package:flutter/services.dart';

/// Files opened with the app from elsewhere (a file manager, a mail, a
/// chat), handed over by the Android activity.
abstract final class IncomingFiles {
  static const _channel = MethodChannel('shopping_list/incoming');

  /// Calls [onReceived] with the content of every file opened with the app,
  /// starting with the one that launched it.
  static Future<void> listen(void Function(String content) onReceived) async {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'received') onReceived(call.arguments as String);
    });
    final pending = await _channel.invokeMethod<String>('take');
    if (pending != null) onReceived(pending);
  }
}
