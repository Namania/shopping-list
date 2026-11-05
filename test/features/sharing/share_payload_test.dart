import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';
import 'package:shopping_list/core/utils/compressed_json.dart';
import 'package:shopping_list/features/sharing/share_payload.dart';
import 'package:uuid/uuid.dart';

/// A big weekly list as the app writes it: ids, a category per article.
List<Map<String, dynamic>> bigList() {
  const uuid = Uuid();
  final categories = [
    for (final (i, label) in [
      'Fruits et légumes',
      'Frais',
      'Crèmerie',
      'Boucherie',
      'Épicerie',
      'Boissons',
      'Hygiène',
      'Produits ménagers',
    ].indexed)
      {'label': label, 'color': 0xFF000000 + i * 0x123456},
  ];
  return [
    {
      'id': uuid.v4(),
      'label': 'Courses de la semaine',
      'card': '',
      'articles': [
        for (var i = 0; i < 40; i++)
          {
            'id': uuid.v4(),
            'label': 'Article numéro $i',
            'category': categories[i % categories.length],
            'done': i % 5 == 0,
          },
      ],
    },
  ];
}

int qrVersion(String data) =>
    QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.L).typeNumber;

void main() {
  test('a big list makes a much smaller QR code than before', () {
    final items = bigList();
    final before =
        '${SharePayload.scheme}://${SharePayload.host}?data='
        '${Uri.encodeComponent(compressJson(jsonEncode({'action': 'importArticles', 'json': items})))}';
    final after = SharePayload(ShareKind.lists, items).toDeepLink();
    // ignore: avoid_print
    print(
      'before: ${before.length} chars, QR v${qrVersion(before)} · after: ${after.length} chars, QR v${qrVersion(after)}',
    );
    expect(after.length, lessThan(before.length / 2));
  });

  test('what is shared comes back the same, minus the ids', () {
    final items = bigList();
    final decoded = SharePayload.fromUri(Uri.parse(SharePayload(ShareKind.lists, items).toDeepLink()))!;
    expect(decoded.kind, ShareKind.lists);
    final list = decoded.items.single;
    expect(list['label'], 'Courses de la semaine');
    final articles = (list['articles'] as List<dynamic>).cast<Map<String, dynamic>>();
    final original = (items.single['articles'] as List<dynamic>).cast<Map<String, dynamic>>();
    expect(articles, hasLength(40));
    for (final (i, a) in articles.indexed) {
      expect(a['label'], original[i]['label']);
      expect(a['category'], original[i]['category']);
      expect(a['done'], original[i]['done']);
    }
  });

  test('cards and categories keep their colours and format', () {
    final cards = SharePayload.fromUri(
      Uri.parse(
        const SharePayload(ShareKind.cards, [
          {'id': 'x', 'label': 'Store', 'code': '2501234567890', 'color': 0xFF1E5BC6, 'format': 'ean13'},
        ]).toDeepLink(),
      ),
    )!;
    expect(cards.items.single, {
      'label': 'Store',
      'code': '2501234567890',
      'color': 0xFF1E5BC6,
      'format': 'ean13',
    });

    final categories = SharePayload.fromUri(
      Uri.parse(
        const SharePayload(ShareKind.categories, [
          {'label': 'Fruits', 'color': 0x8043A047},
        ]).toDeepLink(),
      ),
    )!;
    // Translucent colours arrive opaque, so they never blend into the page.
    expect(categories.items.single, {'label': 'Fruits', 'color': 0xFF43A047});
  });

  test('links of older versions are still read', () {
    final legacy = Uri.parse(
      '${SharePayload.scheme}://${SharePayload.host}?data='
      '${Uri.encodeComponent(compressJson(jsonEncode({
        'action': 'importCategories',
        'json': [
          {'label': 'Fruits', 'color': 1},
        ],
      })))}',
    );
    expect(SharePayload.fromUri(legacy)!.items.single['label'], 'Fruits');
  });

  test('a card without colour arrives in the fallback colour, not black', () {
    final cards = SharePayload.fromUri(
      Uri.parse(
        const SharePayload(ShareKind.cards, [
          {'label': 'Old', 'code': '1', 'color': 0},
          {'label': 'Older', 'code': '2'},
        ]).toDeepLink(),
      ),
    )!;
    expect([for (final c in cards.items) c['color']], [0xFF545A92, 0xFF545A92]);
  });

  test('a damaged link is refused', () {
    expect(SharePayload.fromUri(Uri.parse('shopping-list://launch?d=abc')), isNull);
    expect(SharePayload.fromUri(Uri.parse('shopping-list://launch?data=abc')), isNull);
  });
}
