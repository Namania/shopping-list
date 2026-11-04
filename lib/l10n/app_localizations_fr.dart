// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get calculatorAddButton => 'Ajouter un montant';

  @override
  String get calculatorAddHint => 'Entrez le montant de l\'article';

  @override
  String calculatorAmount(String amount) {
    return '$amount €';
  }

  @override
  String get calculatorClearAll => 'Tout effacer';

  @override
  String get calculatorClearTitle => 'Quels montants effacer ?';

  @override
  String get calculatorClearWithArticle => 'Ceux des articles';

  @override
  String get calculatorClearWithoutArticle => 'Ceux ajoutés à la main';

  @override
  String get calculatorConfirmDelete => 'Voulez-vous vraiment le supprimer ?';

  @override
  String get calculatorEmpty =>
      'Aucun montant pour l\'instant.\nCoche un article pour noter son prix, ou ajoute un montant.';

  @override
  String get calculatorTitle => 'Calculatrice';

  @override
  String get calculatorTotal => 'Total';

  @override
  String get calculatorWithoutArticle => 'Montant libre';

  @override
  String get cardsAdd => 'Ajouter une carte';

  @override
  String get cardsConfirmDelete => 'Voulez-vous vraiment la supprimer ?';

  @override
  String get cardsEmpty =>
      'Aucune carte de fidélité.\nAjoute-la une fois, montre-la en caisse.';

  @override
  String get cardsFormAddTitle => 'Ajouter une carte';

  @override
  String get cardsFormCodeHint => 'Numéro de la carte';

  @override
  String get cardsFormEditTitle => 'Modifier une carte';

  @override
  String get cardsFormNameHint => 'Nom du magasin';

  @override
  String cardsInvalidCode(String format) {
    return 'Ce code ne peut pas être affiché au format $format. Modifiez la carte pour changer le format.';
  }

  @override
  String get cardsTitle => 'Mes cartes';

  @override
  String get categoriesAdd => 'Ajouter une catégorie';

  @override
  String get categoriesConfirmDelete => 'Voulez-vous vraiment la supprimer ?';

  @override
  String get categoriesConfirmDeleteAll =>
      'Voulez-vous vraiment tout supprimer ?';

  @override
  String get categoriesEmpty =>
      'Aucune catégorie.\nRange tes articles par rayon.';

  @override
  String get categoriesExists => 'Une catégorie existe déjà avec ce nom !';

  @override
  String get categoriesFormAddTitle => 'Ajouter une catégorie';

  @override
  String get categoriesFormEditTitle => 'Modifier la catégorie';

  @override
  String get categoriesFormNameHint => 'Nom de la catégorie';

  @override
  String get categoriesTitle => 'Mes catégories';

  @override
  String get categoriesUncategorized => 'Sans catégorie';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Confirmez';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String commonDeleted(String name) {
    return '« $name » supprimé';
  }

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonImport => 'Importer';

  @override
  String get commonLink => 'Lier une carte';

  @override
  String get commonMove => 'Réorganiser';

  @override
  String get commonNo => 'Non';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonUndo => 'Annuler';

  @override
  String get commonUnlink => 'Délier la carte';

  @override
  String get commonYes => 'Oui';

  @override
  String get deepLinkError =>
      'Une erreur s\'est produite.\nVeuillez nous excuser pour le dérangement.';

  @override
  String get deepLinkHome => 'Retourner à l\'accueil';

  @override
  String get listAllDone => 'Tout est dans le panier !';

  @override
  String get listClear => 'Vider la liste';

  @override
  String get listClearDoneOnly => 'Cochés uniquement';

  @override
  String get listConfirmClear => 'Voulez-vous vraiment tout supprimer ?';

  @override
  String get listConfirmDelete => 'Voulez-vous vraiment le supprimer ?';

  @override
  String get listEmpty => 'Liste vide.\nAjoute ton premier article en bas.';

  @override
  String listExists(String name) {
    return 'L\'article « $name » est déjà dans la liste !';
  }

  @override
  String get listFormAddTitle => 'Ajouter un article';

  @override
  String get listFormEditTitle => 'Modifier un article';

  @override
  String get listFormLabelHint => 'Entrez le nom de l\'article';

  @override
  String listInCart(int count) {
    return 'Dans le panier ($count)';
  }

  @override
  String get listLinkCardTitle => 'Lier une carte';

  @override
  String get listMoreOptions => 'Choisir une catégorie';

  @override
  String get listQuickAdd => 'Ajouter un article…';

  @override
  String get listsAdd => 'Nouvelle liste';

  @override
  String get listsComplete => 'Tout est dans le panier';

  @override
  String get listsConfirmDelete => 'Voulez-vous vraiment la supprimer ?';

  @override
  String listsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '$count article',
      zero: 'Pas d\'article',
    );
    return '$_temp0';
  }

  @override
  String get listsEmpty =>
      'Aucune liste pour l\'instant.\nCommence par une de ces idées, ou crée la tienne.';

  @override
  String listsExists(String name) {
    return 'La liste « $name » existe déjà !';
  }

  @override
  String get listsFormAddTitle => 'Ajouter une liste';

  @override
  String get listsFormEditTitle => 'Modifier la liste';

  @override
  String get listsFormLabelHint => 'Entrez le nom de la liste';

  @override
  String listsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles à acheter',
      one: '$count article à acheter',
      zero: 'Tout est dans le panier',
    );
    return '$_temp0';
  }

  @override
  String get listsNoCards => 'Veuillez d\'abord ajouter une carte !';

  @override
  String listsProgress(int done, int total) {
    return '$done / $total dans le panier';
  }

  @override
  String get listsTitle => 'Mes listes';

  @override
  String get navCards => 'Cartes';

  @override
  String get navLists => 'Listes';

  @override
  String get navSettings => 'Réglages';

  @override
  String get settingsAmbiancesForest => 'Forêt';

  @override
  String get settingsAmbiancesFresh => 'Fraîche';

  @override
  String get settingsAmbiancesLavender => 'Lavande';

  @override
  String get settingsAmbiancesOcean => 'Océan';

  @override
  String get settingsAmbiancesRose => 'Rose';

  @override
  String get settingsAmbiancesWarm => 'Chaleureuse';

  @override
  String settingsCalculatorOffConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Désactiver la calculatrice efface les $count montants enregistrés. Continuer ?',
      one:
          'Désactiver la calculatrice efface le montant enregistré. Continuer ?',
    );
    return '$_temp0';
  }

  @override
  String settingsCategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catégories',
      one: '$count catégorie',
      zero: 'Aucune catégorie',
    );
    return '$_temp0';
  }

  @override
  String get settingsItemsAmbiance => 'Ambiance';

  @override
  String get settingsItemsAuthor => 'Développé par';

  @override
  String get settingsItemsBackup => 'Sauvegarde';

  @override
  String get settingsItemsBackupHint =>
      'Un fichier complet, à envoyer ou garder';

  @override
  String get settingsItemsCalculatorEnabled => 'Calculatrice';

  @override
  String get settingsItemsCalculatorHint =>
      'Demande le prix quand tu coches un article';

  @override
  String get settingsItemsLanguage => 'Langue';

  @override
  String get settingsItemsStartRoute => 'Écran au lancement';

  @override
  String get settingsItemsTheme => 'Thème';

  @override
  String get settingsItemsUncategorizedFirst => 'Sans catégorie en premier';

  @override
  String get settingsItemsUncategorizedFirstHint =>
      'Les articles sans catégorie en haut de la liste';

  @override
  String get settingsItemsVersion => 'Version';

  @override
  String get settingsSectionsAbout => 'À propos';

  @override
  String get settingsSectionsAppearance => 'Apparence';

  @override
  String get settingsSectionsData => 'Données';

  @override
  String get settingsSectionsLists => 'Listes';

  @override
  String get settingsStartCards => 'Cartes';

  @override
  String get settingsStartLists => 'Listes';

  @override
  String get settingsThemesDark => 'Sombre';

  @override
  String get settingsThemesLight => 'Clair';

  @override
  String get settingsThemesSystem => 'Système';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get shareInvalid => 'Ce contenu n\'est pas un partage valide !';

  @override
  String get shareMessageCards => 'Voici mes cartes !\n[Shopping List]';

  @override
  String get shareMessageCategories =>
      'Voici mes catégories !\n[Shopping List]';

  @override
  String get shareMessageLists => 'Voici ma liste !\n[Shopping List]';

  @override
  String get shareQrHint => 'À scanner avec l\'app, en face à face';

  @override
  String get shareTooBig => 'Trop de données pour un QR code';

  @override
  String get colorTitle => 'Couleur';

  @override
  String get colorCustom => 'Autre couleur';

  @override
  String categoriesArticleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String categoriesConfirmDeleteUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count articles utilisent cette catégorie et passeront « Sans catégorie ». Supprimer ?',
      one:
          '1 article utilise cette catégorie et passera « Sans catégorie ». Supprimer ?',
    );
    return '$_temp0';
  }

  @override
  String get categoriesDelete => 'Supprimer la catégorie';

  @override
  String get categoriesReorderHint => 'Reste appuyé pour déplacer';

  @override
  String get categoriesOrderHint =>
      'L\'ordre de tes catégories est l\'ordre des rayons dans tes listes. Reste appuyé sur une catégorie puis fais-la glisser pour suivre ton magasin.';

  @override
  String get listClearAll => 'Tout supprimer';

  @override
  String get settingsCalculatorTurnOff => 'Désactiver et effacer';

  @override
  String get cardsScan => 'Scanner la carte';

  @override
  String get cardsFormat => 'Format du code-barres';

  @override
  String get cardsDelete => 'Supprimer la carte';

  @override
  String get cardsBrightnessHint => 'Luminosité au maximum pour la caisse';

  @override
  String get cardsLinkedLists => 'Utilisée pour';

  @override
  String cardsUsedFor(String lists) {
    return 'Pour : $lists';
  }

  @override
  String cardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0';
  }

  @override
  String get listsSuggestions =>
      'Courses de la semaine|Apéro|Pharmacie|Barbecue|Bricolage|Pique-nique';

  @override
  String get listsIdeas => 'Idées';

  @override
  String get listsDuplicateFrom => 'Partir d\'une liste existante';

  @override
  String listsCopyOf(String name) {
    return '$name (copie)';
  }

  @override
  String listsRestarted(String name) {
    return '« $name » est prête pour une nouvelle fois';
  }

  @override
  String get listsRestart => 'Recommencer';

  @override
  String get listsFinished => 'Terminées';

  @override
  String get listRename => 'Renommer';

  @override
  String get listDuplicate => 'Dupliquer';

  @override
  String get listDeleteList => 'Supprimer la liste';

  @override
  String get commonValidate => 'Valider';

  @override
  String get calculatorDelete => 'Supprimer le montant';

  @override
  String get calculatorAllLists => 'Toutes les listes';

  @override
  String get calculatorNoList => 'Hors liste';

  @override
  String calculatorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count montants',
      one: '1 montant',
      zero: 'Aucun montant',
    );
    return '$_temp0';
  }

  @override
  String get shareTitle => 'Partager';

  @override
  String get shareText => 'En texte';

  @override
  String get shareTextHint => 'Un message lisible partout, même sans l\'app';

  @override
  String get shareQr => 'QR code';

  @override
  String get shareFile => 'Fichier';

  @override
  String get shareFileHint => 'À ouvrir avec l\'app sur un autre téléphone';

  @override
  String get shareQrScanHint =>
      'Sur l\'autre téléphone : Importer, puis Scanner un QR code.';

  @override
  String get shareOtherWays => 'Autres façons de partager';

  @override
  String shareWhatLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listes',
      one: '1 liste',
    );
    return '$_temp0';
  }

  @override
  String shareWhatCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0';
  }

  @override
  String shareWhatCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catégories',
      one: '1 catégorie',
    );
    return '$_temp0';
  }

  @override
  String get importTitle => 'Importer';

  @override
  String get importSubtitle => 'Un QR code, un fichier ou un lien reçu';

  @override
  String get importScan => 'Scanner un QR code';

  @override
  String get importScanHint => 'Montré par l\'app sur un autre téléphone';

  @override
  String get importFile => 'Ouvrir un fichier';

  @override
  String get importFileHint => 'Une sauvegarde ou un fichier partagé';

  @override
  String get importPaste => 'Coller un lien';

  @override
  String get importPasteHint => 'Un lien Shopping List copié';

  @override
  String get importEmpty => 'Il n\'y a rien à importer.';

  @override
  String get importDone => 'Importé';

  @override
  String get importRestored => 'Sauvegarde restaurée';

  @override
  String get importReceived => 'Données reçues';

  @override
  String get importBackup => 'Sauvegarde';

  @override
  String importBackupOf(String date, String time) {
    return 'Sauvegarde du $date à $time';
  }

  @override
  String get importAll => 'Tout';

  @override
  String get importNone => 'Aucun';

  @override
  String importAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count éléments',
      one: 'Ajouter 1 élément',
      zero: 'Rien de coché',
    );
    return '$_temp0';
  }

  @override
  String get importReplace => 'Tout remplacer par cette sauvegarde';

  @override
  String get importReplaceConfirm =>
      'Tes données actuelles seront remplacées. Une copie est gardée dans les points de restauration.';

  @override
  String get importCategories => 'Catégories';

  @override
  String get backupTitle => 'Sauvegarde';

  @override
  String get backupSubtitle =>
      'Toutes tes données dans un seul fichier, montants compris';

  @override
  String get backupSend => 'Envoyer une sauvegarde';

  @override
  String get backupSendHint => 'Vers Drive, un mail, une conversation…';

  @override
  String get backupSave => 'Enregistrer sur le téléphone';

  @override
  String get backupSaveHint => 'Dans le dossier de ton choix';

  @override
  String get backupRestore => 'Restaurer une sauvegarde';

  @override
  String get backupRestoreHint => 'Tu verras son contenu avant de choisir';

  @override
  String get backupSaved => 'Sauvegarde enregistrée';

  @override
  String get restorePointsTitle => 'Points de restauration';

  @override
  String get restorePointsSubtitle =>
      'Des copies gardées sur le téléphone. Touche-en une pour revenir à ce moment-là.';

  @override
  String get restorePointsEmpty =>
      'Aucune copie pour l\'instant : la première sera faite demain.';

  @override
  String get restorePointDaily => 'Copie du jour';

  @override
  String get restorePointBeforeImport => 'Avant un import';

  @override
  String get restorePointBeforeRestore => 'Avant une restauration';

  @override
  String restorePointConfirm(String when) {
    return 'Revenir aux données du $when ? Les données actuelles sont gardées en copie.';
  }

  @override
  String get restorePointRestore => 'Revenir à cette copie';

  @override
  String get restorePointDone => 'Données restaurées';

  @override
  String get settingsItemsRestorePointsHint =>
      'Une copie automatique chaque jour';

  @override
  String get importReplaceConfirmButton => 'Remplacer mes données';
}
