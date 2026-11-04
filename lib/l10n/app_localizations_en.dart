// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get calculatorAddButton => 'Add an amount';

  @override
  String get calculatorAddHint => 'Enter the amount of the article';

  @override
  String calculatorAmount(String amount) {
    return '\$$amount';
  }

  @override
  String get calculatorClearAll => 'Clear everything';

  @override
  String get calculatorClearTitle => 'Which amounts to clear?';

  @override
  String get calculatorClearWithArticle => 'Those of articles';

  @override
  String get calculatorClearWithoutArticle => 'Those added by hand';

  @override
  String get calculatorConfirmDelete => 'Do you really want to delete it?';

  @override
  String get calculatorEmpty =>
      'No amount yet.\nCheck an article to note its price, or add an amount.';

  @override
  String get calculatorTitle => 'Calculator';

  @override
  String get calculatorTotal => 'Total';

  @override
  String get calculatorWithoutArticle => 'Custom amount';

  @override
  String get cardsAdd => 'Add a card';

  @override
  String get cardsConfirmDelete => 'Do you really want to delete it?';

  @override
  String get cardsEmpty =>
      'No loyalty card.\nAdd it once, show it at the checkout.';

  @override
  String get cardsFormAddTitle => 'Add a card';

  @override
  String get cardsFormCodeHint => 'Card number';

  @override
  String get cardsFormEditTitle => 'Edit the card';

  @override
  String get cardsFormNameHint => 'Store name';

  @override
  String cardsInvalidCode(String format) {
    return 'This code cannot be shown as $format. Edit the card to change the format.';
  }

  @override
  String get cardsTitle => 'My cards';

  @override
  String get categoriesAdd => 'Add a category';

  @override
  String get categoriesConfirmDelete => 'Do you really want to delete it?';

  @override
  String get categoriesConfirmDeleteAll =>
      'Do you really want to delete everything?';

  @override
  String get categoriesEmpty => 'No category.\nSort your items by aisle.';

  @override
  String get categoriesExists => 'A category with this name already exists!';

  @override
  String get categoriesFormAddTitle => 'Add a category';

  @override
  String get categoriesFormEditTitle => 'Edit the category';

  @override
  String get categoriesFormNameHint => 'Category name';

  @override
  String get categoriesTitle => 'My categories';

  @override
  String get categoriesUncategorized => 'Uncategorized';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String commonDeleted(String name) {
    return '\"$name\" deleted';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonImport => 'Import';

  @override
  String get commonLink => 'Link a card';

  @override
  String get commonMove => 'Reorder';

  @override
  String get commonNo => 'No';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonUnlink => 'Unlink the card';

  @override
  String get commonYes => 'Yes';

  @override
  String get deepLinkError =>
      'An error has occurred.\nWe apologize for the inconvenience.';

  @override
  String get deepLinkHome => 'Return to home';

  @override
  String get listAllDone => 'Everything is in the cart!';

  @override
  String get listClear => 'Clear the list';

  @override
  String get listClearDoneOnly => 'Checked only';

  @override
  String get listConfirmClear => 'Do you really want to delete everything?';

  @override
  String get listConfirmDelete => 'Do you really want to delete it?';

  @override
  String get listEmpty => 'Empty list.\nAdd your first item below.';

  @override
  String listExists(String name) {
    return 'The article \"$name\" is already in the list!';
  }

  @override
  String get listFormAddTitle => 'Add an article';

  @override
  String get listFormEditTitle => 'Edit the article';

  @override
  String get listFormLabelHint => 'Enter the name of the article';

  @override
  String listInCart(int count) {
    return 'In the cart ($count)';
  }

  @override
  String get listLinkCardTitle => 'Link a card';

  @override
  String get listMoreOptions => 'Pick a category';

  @override
  String get listQuickAdd => 'Add an item…';

  @override
  String get listsAdd => 'New list';

  @override
  String get listsComplete => 'Everything is in the cart';

  @override
  String get listsConfirmDelete => 'Do you really want to delete it?';

  @override
  String listsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '$count article',
      zero: 'No article',
    );
    return '$_temp0';
  }

  @override
  String get listsEmpty =>
      'No list yet.\nStart with one of these ideas, or create your own.';

  @override
  String listsExists(String name) {
    return 'The list \"$name\" already exists!';
  }

  @override
  String get listsFormAddTitle => 'Add a list';

  @override
  String get listsFormEditTitle => 'Rename the list';

  @override
  String get listsFormLabelHint => 'Enter the name of the list';

  @override
  String listsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to buy',
      one: '$count item to buy',
      zero: 'Everything is in the cart',
    );
    return '$_temp0';
  }

  @override
  String get listsNoCards => 'Please add a card first!';

  @override
  String listsProgress(int done, int total) {
    return '$done / $total in the cart';
  }

  @override
  String get listsTitle => 'My lists';

  @override
  String get navCards => 'Cards';

  @override
  String get navLists => 'Lists';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsAmbiancesForest => 'Forest';

  @override
  String get settingsAmbiancesFresh => 'Fresh';

  @override
  String get settingsAmbiancesLavender => 'Lavender';

  @override
  String get settingsAmbiancesOcean => 'Ocean';

  @override
  String get settingsAmbiancesRose => 'Rose';

  @override
  String get settingsAmbiancesWarm => 'Warm';

  @override
  String settingsCalculatorOffConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Turning the calculator off erases the $count saved amounts. Continue?',
      one: 'Turning the calculator off erases the saved amount. Continue?',
    );
    return '$_temp0';
  }

  @override
  String settingsCategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '$count category',
      zero: 'No category',
    );
    return '$_temp0';
  }

  @override
  String get settingsItemsAmbiance => 'Look';

  @override
  String get settingsItemsAuthor => 'Made by';

  @override
  String get settingsItemsBackup => 'Backup';

  @override
  String get settingsItemsBackupHint => 'A complete file, to send or keep';

  @override
  String get settingsItemsCalculatorEnabled => 'Calculator';

  @override
  String get settingsItemsCalculatorHint =>
      'Asks for the price when you check an item';

  @override
  String get settingsItemsLanguage => 'Language';

  @override
  String get settingsItemsStartRoute => 'Screen at launch';

  @override
  String get settingsItemsTheme => 'Theme';

  @override
  String get settingsItemsUncategorizedFirst => 'Uncategorized first';

  @override
  String get settingsItemsUncategorizedFirstHint =>
      'Items without a category at the top of the list';

  @override
  String get settingsItemsVersion => 'Version';

  @override
  String get settingsSectionsAbout => 'About';

  @override
  String get settingsSectionsAppearance => 'Appearance';

  @override
  String get settingsSectionsData => 'Data';

  @override
  String get settingsSectionsLists => 'Lists';

  @override
  String get settingsStartCards => 'Cards';

  @override
  String get settingsStartLists => 'Lists';

  @override
  String get settingsThemesDark => 'Dark';

  @override
  String get settingsThemesLight => 'Light';

  @override
  String get settingsThemesSystem => 'System';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get shareInvalid => 'This content is not a valid share!';

  @override
  String get shareMessageCards => 'Here are my cards!\n[Shopping List]';

  @override
  String get shareMessageCategories =>
      'Here are my categories!\n[Shopping List]';

  @override
  String get shareMessageLists => 'Here is my list!\n[Shopping List]';

  @override
  String get shareQrHint => 'To scan with the app, face to face';

  @override
  String get shareTooBig => 'Too much data for a QR code';

  @override
  String get colorTitle => 'Colour';

  @override
  String get colorCustom => 'Other colour';

  @override
  String categoriesArticleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No item',
    );
    return '$_temp0';
  }

  @override
  String categoriesConfirmDeleteUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count items use this category and will become uncategorized. Delete?',
      one: '1 item uses this category and will become uncategorized. Delete?',
    );
    return '$_temp0';
  }

  @override
  String get categoriesDelete => 'Delete the category';

  @override
  String get categoriesReorderHint => 'Press and hold to move';

  @override
  String get categoriesOrderHint =>
      'The order of your categories is the order of the aisles in your lists. Press and hold a category, then drag it to match your store.';

  @override
  String get listClearAll => 'Delete everything';

  @override
  String get settingsCalculatorTurnOff => 'Turn off and erase';

  @override
  String get cardsScan => 'Scan the card';

  @override
  String get cardsFormat => 'Barcode format';

  @override
  String get cardsDelete => 'Delete the card';

  @override
  String get cardsBrightnessHint => 'Full brightness for the checkout';

  @override
  String get cardsLinkedLists => 'Used for';

  @override
  String cardsUsedFor(String lists) {
    return 'For: $lists';
  }

  @override
  String cardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get listsSuggestions =>
      'Weekly groceries|Drinks party|Pharmacy|Barbecue|DIY|Picnic';

  @override
  String get listsIdeas => 'Ideas';

  @override
  String get listsDuplicateFrom => 'Start from an existing list';

  @override
  String listsCopyOf(String name) {
    return '$name (copy)';
  }

  @override
  String listsRestarted(String name) {
    return '“$name” is ready to shop again';
  }

  @override
  String get listsRestart => 'Start over';

  @override
  String get listsFinished => 'Done';

  @override
  String get listRename => 'Rename';

  @override
  String get listDuplicate => 'Duplicate';

  @override
  String get listDeleteList => 'Delete list';

  @override
  String get commonValidate => 'Confirm';

  @override
  String get calculatorDelete => 'Delete amount';

  @override
  String get calculatorAllLists => 'All lists';

  @override
  String get calculatorNoList => 'No list';

  @override
  String calculatorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amounts',
      one: '1 amount',
      zero: 'No amount',
    );
    return '$_temp0';
  }

  @override
  String get shareTitle => 'Share';

  @override
  String get shareText => 'As text';

  @override
  String get shareTextHint => 'A message anyone can read, even without the app';

  @override
  String get shareQr => 'QR code';

  @override
  String get shareFile => 'File';

  @override
  String get shareFileHint => 'To open with the app on another phone';

  @override
  String get shareQrScanHint =>
      'On the other phone: Import, then Scan a QR code.';

  @override
  String get shareOtherWays => 'Other ways to share';

  @override
  String shareWhatLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lists',
      one: '1 list',
    );
    return '$_temp0';
  }

  @override
  String shareWhatCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String shareWhatCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return '$_temp0';
  }

  @override
  String get importTitle => 'Import';

  @override
  String get importSubtitle => 'A QR code, a file or a link you received';

  @override
  String get importScan => 'Scan a QR code';

  @override
  String get importScanHint => 'Shown by the app on another phone';

  @override
  String get importFile => 'Open a file';

  @override
  String get importFileHint => 'A backup or a shared file';

  @override
  String get importPaste => 'Paste a link';

  @override
  String get importPasteHint => 'A copied Shopping List link';

  @override
  String get importEmpty => 'There is nothing to import.';

  @override
  String get importDone => 'Imported';

  @override
  String get importRestored => 'Backup restored';

  @override
  String get importReceived => 'Received data';

  @override
  String get importBackup => 'Backup';

  @override
  String importBackupOf(String date, String time) {
    return 'Backup of $date at $time';
  }

  @override
  String get importAll => 'All';

  @override
  String get importNone => 'None';

  @override
  String importAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items',
      one: 'Add 1 item',
      zero: 'Nothing ticked',
    );
    return '$_temp0';
  }

  @override
  String get importReplace => 'Replace everything with this backup';

  @override
  String get importReplaceConfirm =>
      'Your current data will be replaced. A copy is kept in the restore points.';

  @override
  String get importCategories => 'Categories';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupSubtitle => 'All your data in one file, amounts included';

  @override
  String get backupSend => 'Send a backup';

  @override
  String get backupSendHint => 'To Drive, an email, a chat…';

  @override
  String get backupSave => 'Save on the phone';

  @override
  String get backupSaveHint => 'In the folder you choose';

  @override
  String get backupRestore => 'Restore a backup';

  @override
  String get backupRestoreHint => 'You\'ll see what it holds before choosing';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get restorePointsTitle => 'Restore points';

  @override
  String get restorePointsSubtitle =>
      'Copies kept on the phone. Tap one to go back to that moment.';

  @override
  String get restorePointsEmpty =>
      'No copy yet: the first one will be made tomorrow.';

  @override
  String get restorePointDaily => 'Daily copy';

  @override
  String get restorePointBeforeImport => 'Before an import';

  @override
  String get restorePointBeforeRestore => 'Before a restore';

  @override
  String restorePointConfirm(String when) {
    return 'Go back to the data of $when? The current data is kept as a copy.';
  }

  @override
  String get restorePointRestore => 'Go back to this copy';

  @override
  String get restorePointDone => 'Data restored';

  @override
  String get settingsItemsRestorePointsHint => 'An automatic copy every day';

  @override
  String get importReplaceConfirmButton => 'Replace my data';
}
