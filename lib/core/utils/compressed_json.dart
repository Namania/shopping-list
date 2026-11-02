import 'dart:convert';
import 'dart:io';

/// JSON ⇄ zlib-compressed, URL-safe base64. Used to fit a whole list in a
/// QR code / deep link.
String compressJson(String json) => base64Url.encode(ZLibCodec().encode(utf8.encode(json)));

String decompressJson(String compressed) => utf8.decode(ZLibCodec().decode(base64Url.decode(compressed)));
