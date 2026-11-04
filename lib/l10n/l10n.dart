import 'package:flutter/widgets.dart';
import 'package:shopping_list/l10n/app_localizations.dart';

export 'package:shopping_list/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's strings in the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// French when the phone is in French, English otherwise.
Locale resolveLocale(Locale? device, Iterable<Locale> supported) =>
    device?.languageCode == 'fr' ? const Locale('fr') : const Locale('en');
