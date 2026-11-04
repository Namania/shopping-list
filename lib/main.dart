import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shopping_list/bootstrap.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // The bundled fonts' licences, listed in the app's licence page.
  LicenseRegistry.addLicense(() async* {
    for (final (font, file) in [('Bricolage Grotesque', 'BricolageGrotesque'), ('Figtree', 'Figtree')]) {
      yield LicenseEntryWithLineBreaks([font], await rootBundle.loadString('assets/fonts/OFL-$file.txt'));
    }
  });
  runApp(await bootstrap());
  FlutterNativeSplash.remove();
}
