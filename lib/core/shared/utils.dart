import 'dart:convert';
import 'dart:io';

class Utils {

  static String compressJson(String json) {
    final inputBytes = utf8.encode(json);
    final compressed = ZLibCodec().encode(inputBytes);
    return base64Url.encode(compressed);
  }

  static String decompressJson(String compressedBase64) {
    final compressedBytes = base64Url.decode(compressedBase64);
    final decompressedBytes = ZLibCodec().decode(compressedBytes);
    final json = utf8.decode(decompressedBytes);
    return json;
  }

}