import 'dart:convert';

import 'package:shopping_list/core/utils/compressed_json.dart';

/// What a share payload contains. The wire names are those of the first
/// versions of the app so QR codes keep working across versions.
enum ShareKind {
  lists('importArticles', '/lists'),
  categories('importCategories', '/categories'),
  cards('importCards', '/cards');

  final String action;

  /// Page to show once the payload is imported.
  final String route;

  const ShareKind(this.action, this.route);

  static ShareKind? fromAction(String? action) => values.where((kind) => kind.action == action).firstOrNull;
}

/// A collection shared through a QR code / deep link
/// (`shopping-list://launch?data=<compressed json>`).
class SharePayload {
  static const scheme = 'shopping-list';
  static const host = 'launch';

  final ShareKind kind;
  final List<Map<String, dynamic>> items;

  const SharePayload(this.kind, this.items);

  String toDeepLink() {
    final json = jsonEncode({'action': kind.action, 'json': items});
    return '$scheme://$host?data=${Uri.encodeComponent(compressJson(json))}';
  }

  static bool isDeepLink(Uri uri) => uri.scheme == scheme && uri.host == host;

  /// Decodes the `data` query parameter of a deep link, `null` when it is not
  /// a valid payload.
  static SharePayload? decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final map = jsonDecode(decompressJson(data)) as Map<String, dynamic>;
      final kind = ShareKind.fromAction(map['action'] as String?);
      if (kind == null) return null;
      return SharePayload(kind, (map['json'] as List<dynamic>).cast<Map<String, dynamic>>());
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
