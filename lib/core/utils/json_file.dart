import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Lets the user pick a `.json` file and returns its decoded content, or
/// `null` when the picker is cancelled. Throws a [FormatException] when the
/// file is not valid JSON.
Future<Object?> pickJsonFile() async {
  final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['json']);
  if (file == null) return null;
  return jsonDecode(await file.xFile.readAsString());
}
