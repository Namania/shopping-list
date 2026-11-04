import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @calculatorAddButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un montant'**
  String get calculatorAddButton;

  /// No description provided for @calculatorAddHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le montant de l\'article'**
  String get calculatorAddHint;

  /// No description provided for @calculatorAmount.
  ///
  /// In fr, this message translates to:
  /// **'{amount} €'**
  String calculatorAmount(String amount);

  /// No description provided for @calculatorClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get calculatorClearAll;

  /// No description provided for @calculatorClearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quels montants effacer ?'**
  String get calculatorClearTitle;

  /// No description provided for @calculatorClearWithArticle.
  ///
  /// In fr, this message translates to:
  /// **'Ceux des articles'**
  String get calculatorClearWithArticle;

  /// No description provided for @calculatorClearWithoutArticle.
  ///
  /// In fr, this message translates to:
  /// **'Ceux ajoutés à la main'**
  String get calculatorClearWithoutArticle;

  /// No description provided for @calculatorConfirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment le supprimer ?'**
  String get calculatorConfirmDelete;

  /// No description provided for @calculatorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun montant pour l\'instant.\nCoche un article pour noter son prix, ou ajoute un montant.'**
  String get calculatorEmpty;

  /// No description provided for @calculatorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calculatrice'**
  String get calculatorTitle;

  /// No description provided for @calculatorTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get calculatorTotal;

  /// No description provided for @calculatorWithoutArticle.
  ///
  /// In fr, this message translates to:
  /// **'Montant libre'**
  String get calculatorWithoutArticle;

  /// No description provided for @cardsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une carte'**
  String get cardsAdd;

  /// No description provided for @cardsConfirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment la supprimer ?'**
  String get cardsConfirmDelete;

  /// No description provided for @cardsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune carte de fidélité.\nAjoute-la une fois, montre-la en caisse.'**
  String get cardsEmpty;

  /// No description provided for @cardsFormAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une carte'**
  String get cardsFormAddTitle;

  /// No description provided for @cardsFormCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de la carte'**
  String get cardsFormCodeHint;

  /// No description provided for @cardsFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier une carte'**
  String get cardsFormEditTitle;

  /// No description provided for @cardsFormNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom du magasin'**
  String get cardsFormNameHint;

  /// No description provided for @cardsInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Ce code ne peut pas être affiché au format {format}. Modifiez la carte pour changer le format.'**
  String cardsInvalidCode(String format);

  /// No description provided for @cardsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes cartes'**
  String get cardsTitle;

  /// No description provided for @categoriesAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une catégorie'**
  String get categoriesAdd;

  /// No description provided for @categoriesConfirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment la supprimer ?'**
  String get categoriesConfirmDelete;

  /// No description provided for @categoriesConfirmDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment tout supprimer ?'**
  String get categoriesConfirmDeleteAll;

  /// No description provided for @categoriesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune catégorie.\nRange tes articles par rayon.'**
  String get categoriesEmpty;

  /// No description provided for @categoriesExists.
  ///
  /// In fr, this message translates to:
  /// **'Une catégorie existe déjà avec ce nom !'**
  String get categoriesExists;

  /// No description provided for @categoriesFormAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une catégorie'**
  String get categoriesFormAddTitle;

  /// No description provided for @categoriesFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la catégorie'**
  String get categoriesFormEditTitle;

  /// No description provided for @categoriesFormNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la catégorie'**
  String get categoriesFormNameHint;

  /// No description provided for @categoriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes catégories'**
  String get categoriesTitle;

  /// No description provided for @categoriesUncategorized.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get categoriesUncategorized;

  /// No description provided for @commonAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get commonAdd;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonDeleted.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » supprimé'**
  String commonDeleted(String name);

  /// No description provided for @commonDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get commonDone;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get commonImport;

  /// No description provided for @commonLink.
  ///
  /// In fr, this message translates to:
  /// **'Lier une carte'**
  String get commonLink;

  /// No description provided for @commonMove.
  ///
  /// In fr, this message translates to:
  /// **'Réorganiser'**
  String get commonMove;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get commonShare;

  /// No description provided for @commonUndo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonUndo;

  /// No description provided for @commonUnlink.
  ///
  /// In fr, this message translates to:
  /// **'Délier la carte'**
  String get commonUnlink;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @deepLinkError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite.\nVeuillez nous excuser pour le dérangement.'**
  String get deepLinkError;

  /// No description provided for @deepLinkHome.
  ///
  /// In fr, this message translates to:
  /// **'Retourner à l\'accueil'**
  String get deepLinkHome;

  /// No description provided for @listAllDone.
  ///
  /// In fr, this message translates to:
  /// **'Tout est dans le panier !'**
  String get listAllDone;

  /// No description provided for @listClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider la liste'**
  String get listClear;

  /// No description provided for @listClearDoneOnly.
  ///
  /// In fr, this message translates to:
  /// **'Cochés uniquement'**
  String get listClearDoneOnly;

  /// No description provided for @listConfirmClear.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment tout supprimer ?'**
  String get listConfirmClear;

  /// No description provided for @listConfirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment le supprimer ?'**
  String get listConfirmDelete;

  /// No description provided for @listEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Liste vide.\nAjoute ton premier article en bas.'**
  String get listEmpty;

  /// No description provided for @listExists.
  ///
  /// In fr, this message translates to:
  /// **'L\'article « {name} » est déjà dans la liste !'**
  String listExists(String name);

  /// No description provided for @listFormAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un article'**
  String get listFormAddTitle;

  /// No description provided for @listFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier un article'**
  String get listFormEditTitle;

  /// No description provided for @listFormLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le nom de l\'article'**
  String get listFormLabelHint;

  /// No description provided for @listInCart.
  ///
  /// In fr, this message translates to:
  /// **'Dans le panier ({count})'**
  String listInCart(int count);

  /// No description provided for @listLinkCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lier une carte'**
  String get listLinkCardTitle;

  /// No description provided for @listMoreOptions.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une catégorie'**
  String get listMoreOptions;

  /// No description provided for @listQuickAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un article…'**
  String get listQuickAdd;

  /// No description provided for @listsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle liste'**
  String get listsAdd;

  /// No description provided for @listsComplete.
  ///
  /// In fr, this message translates to:
  /// **'Tout est dans le panier'**
  String get listsComplete;

  /// No description provided for @listsConfirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment la supprimer ?'**
  String get listsConfirmDelete;

  /// No description provided for @listsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Pas d\'article} =1{{count} article} other{{count} articles}}'**
  String listsCount(int count);

  /// No description provided for @listsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune liste pour l\'instant.\nCommence par une de ces idées, ou crée la tienne.'**
  String get listsEmpty;

  /// No description provided for @listsExists.
  ///
  /// In fr, this message translates to:
  /// **'La liste « {name} » existe déjà !'**
  String listsExists(String name);

  /// No description provided for @listsFormAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une liste'**
  String get listsFormAddTitle;

  /// No description provided for @listsFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la liste'**
  String get listsFormEditTitle;

  /// No description provided for @listsFormLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le nom de la liste'**
  String get listsFormLabelHint;

  /// No description provided for @listsLeft.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Tout est dans le panier} =1{{count} article à acheter} other{{count} articles à acheter}}'**
  String listsLeft(int count);

  /// No description provided for @listsNoCards.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez d\'abord ajouter une carte !'**
  String get listsNoCards;

  /// No description provided for @listsProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} dans le panier'**
  String listsProgress(int done, int total);

  /// No description provided for @listsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes listes'**
  String get listsTitle;

  /// No description provided for @navCards.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get navCards;

  /// No description provided for @navLists.
  ///
  /// In fr, this message translates to:
  /// **'Listes'**
  String get navLists;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @settingsAmbiancesForest.
  ///
  /// In fr, this message translates to:
  /// **'Forêt'**
  String get settingsAmbiancesForest;

  /// No description provided for @settingsAmbiancesFresh.
  ///
  /// In fr, this message translates to:
  /// **'Fraîche'**
  String get settingsAmbiancesFresh;

  /// No description provided for @settingsAmbiancesLavender.
  ///
  /// In fr, this message translates to:
  /// **'Lavande'**
  String get settingsAmbiancesLavender;

  /// No description provided for @settingsAmbiancesOcean.
  ///
  /// In fr, this message translates to:
  /// **'Océan'**
  String get settingsAmbiancesOcean;

  /// No description provided for @settingsAmbiancesRose.
  ///
  /// In fr, this message translates to:
  /// **'Rose'**
  String get settingsAmbiancesRose;

  /// No description provided for @settingsAmbiancesWarm.
  ///
  /// In fr, this message translates to:
  /// **'Chaleureuse'**
  String get settingsAmbiancesWarm;

  /// No description provided for @settingsCalculatorOffConfirm.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Désactiver la calculatrice efface le montant enregistré. Continuer ?} other{Désactiver la calculatrice efface les {count} montants enregistrés. Continuer ?}}'**
  String settingsCalculatorOffConfirm(int count);

  /// No description provided for @settingsCategoriesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune catégorie} =1{{count} catégorie} other{{count} catégories}}'**
  String settingsCategoriesCount(int count);

  /// No description provided for @settingsItemsAmbiance.
  ///
  /// In fr, this message translates to:
  /// **'Ambiance'**
  String get settingsItemsAmbiance;

  /// No description provided for @settingsItemsAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Développé par'**
  String get settingsItemsAuthor;

  /// No description provided for @settingsItemsBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get settingsItemsBackup;

  /// No description provided for @settingsItemsBackupHint.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier complet, à envoyer ou garder'**
  String get settingsItemsBackupHint;

  /// No description provided for @settingsItemsCalculatorEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Calculatrice'**
  String get settingsItemsCalculatorEnabled;

  /// No description provided for @settingsItemsCalculatorHint.
  ///
  /// In fr, this message translates to:
  /// **'Demande le prix quand tu coches un article'**
  String get settingsItemsCalculatorHint;

  /// No description provided for @settingsItemsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsItemsLanguage;

  /// No description provided for @settingsItemsStartRoute.
  ///
  /// In fr, this message translates to:
  /// **'Écran au lancement'**
  String get settingsItemsStartRoute;

  /// No description provided for @settingsItemsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsItemsTheme;

  /// No description provided for @settingsItemsUncategorizedFirst.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie en premier'**
  String get settingsItemsUncategorizedFirst;

  /// No description provided for @settingsItemsUncategorizedFirstHint.
  ///
  /// In fr, this message translates to:
  /// **'Les articles sans catégorie en haut de la liste'**
  String get settingsItemsUncategorizedFirstHint;

  /// No description provided for @settingsItemsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settingsItemsVersion;

  /// No description provided for @settingsSectionsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsSectionsAbout;

  /// No description provided for @settingsSectionsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsSectionsAppearance;

  /// No description provided for @settingsSectionsData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsSectionsData;

  /// No description provided for @settingsSectionsLists.
  ///
  /// In fr, this message translates to:
  /// **'Listes'**
  String get settingsSectionsLists;

  /// No description provided for @settingsStartCards.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get settingsStartCards;

  /// No description provided for @settingsStartLists.
  ///
  /// In fr, this message translates to:
  /// **'Listes'**
  String get settingsStartLists;

  /// No description provided for @settingsThemesDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemesDark;

  /// No description provided for @settingsThemesLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemesLight;

  /// No description provided for @settingsThemesSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemesSystem;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @shareInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce contenu n\'est pas un partage valide !'**
  String get shareInvalid;

  /// No description provided for @shareMessageCards.
  ///
  /// In fr, this message translates to:
  /// **'Voici mes cartes !\n[Shopping List]'**
  String get shareMessageCards;

  /// No description provided for @shareMessageCategories.
  ///
  /// In fr, this message translates to:
  /// **'Voici mes catégories !\n[Shopping List]'**
  String get shareMessageCategories;

  /// No description provided for @shareMessageLists.
  ///
  /// In fr, this message translates to:
  /// **'Voici ma liste !\n[Shopping List]'**
  String get shareMessageLists;

  /// No description provided for @shareQrHint.
  ///
  /// In fr, this message translates to:
  /// **'À scanner avec l\'app, en face à face'**
  String get shareQrHint;

  /// No description provided for @shareTooBig.
  ///
  /// In fr, this message translates to:
  /// **'Trop de données pour un QR code'**
  String get shareTooBig;

  /// No description provided for @colorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get colorTitle;

  /// No description provided for @colorCustom.
  ///
  /// In fr, this message translates to:
  /// **'Autre couleur'**
  String get colorCustom;

  /// No description provided for @categoriesArticleCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun article} =1{1 article} other{{count} articles}}'**
  String categoriesArticleCount(int count);

  /// No description provided for @categoriesConfirmDeleteUsed.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article utilise cette catégorie et passera « Sans catégorie ». Supprimer ?} other{{count} articles utilisent cette catégorie et passeront « Sans catégorie ». Supprimer ?}}'**
  String categoriesConfirmDeleteUsed(int count);

  /// No description provided for @categoriesDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la catégorie'**
  String get categoriesDelete;

  /// No description provided for @categoriesReorderHint.
  ///
  /// In fr, this message translates to:
  /// **'Reste appuyé pour déplacer'**
  String get categoriesReorderHint;

  /// No description provided for @categoriesOrderHint.
  ///
  /// In fr, this message translates to:
  /// **'L\'ordre de tes catégories est l\'ordre des rayons dans tes listes. Reste appuyé sur une catégorie puis fais-la glisser pour suivre ton magasin.'**
  String get categoriesOrderHint;

  /// No description provided for @listClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get listClearAll;

  /// No description provided for @settingsCalculatorTurnOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver et effacer'**
  String get settingsCalculatorTurnOff;

  /// No description provided for @cardsScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner la carte'**
  String get cardsScan;

  /// No description provided for @cardsFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format du code-barres'**
  String get cardsFormat;

  /// No description provided for @cardsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la carte'**
  String get cardsDelete;

  /// No description provided for @cardsBrightnessHint.
  ///
  /// In fr, this message translates to:
  /// **'Luminosité au maximum pour la caisse'**
  String get cardsBrightnessHint;

  /// No description provided for @cardsLinkedLists.
  ///
  /// In fr, this message translates to:
  /// **'Utilisée pour'**
  String get cardsLinkedLists;

  /// No description provided for @cardsUsedFor.
  ///
  /// In fr, this message translates to:
  /// **'Pour : {lists}'**
  String cardsUsedFor(String lists);

  /// No description provided for @cardsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 carte} other{{count} cartes}}'**
  String cardsCount(int count);

  /// No description provided for @listsSuggestions.
  ///
  /// In fr, this message translates to:
  /// **'Courses de la semaine|Apéro|Pharmacie|Barbecue|Bricolage|Pique-nique'**
  String get listsSuggestions;

  /// No description provided for @listsIdeas.
  ///
  /// In fr, this message translates to:
  /// **'Idées'**
  String get listsIdeas;

  /// No description provided for @listsDuplicateFrom.
  ///
  /// In fr, this message translates to:
  /// **'Partir d\'une liste existante'**
  String get listsDuplicateFrom;

  /// No description provided for @listsCopyOf.
  ///
  /// In fr, this message translates to:
  /// **'{name} (copie)'**
  String listsCopyOf(String name);

  /// No description provided for @listsRestarted.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » est prête pour une nouvelle fois'**
  String listsRestarted(String name);

  /// No description provided for @listsRestart.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get listsRestart;

  /// No description provided for @listsFinished.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get listsFinished;

  /// No description provided for @listRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get listRename;

  /// No description provided for @listDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get listDuplicate;

  /// No description provided for @listDeleteList.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la liste'**
  String get listDeleteList;

  /// No description provided for @commonValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get commonValidate;

  /// No description provided for @calculatorDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le montant'**
  String get calculatorDelete;

  /// No description provided for @calculatorAllLists.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les listes'**
  String get calculatorAllLists;

  /// No description provided for @calculatorNoList.
  ///
  /// In fr, this message translates to:
  /// **'Hors liste'**
  String get calculatorNoList;

  /// No description provided for @calculatorCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun montant} =1{1 montant} other{{count} montants}}'**
  String calculatorCount(int count);

  /// No description provided for @shareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get shareTitle;

  /// No description provided for @shareText.
  ///
  /// In fr, this message translates to:
  /// **'En texte'**
  String get shareText;

  /// No description provided for @shareTextHint.
  ///
  /// In fr, this message translates to:
  /// **'Un message lisible partout, même sans l\'app'**
  String get shareTextHint;

  /// No description provided for @shareQr.
  ///
  /// In fr, this message translates to:
  /// **'QR code'**
  String get shareQr;

  /// No description provided for @shareFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier'**
  String get shareFile;

  /// No description provided for @shareFileHint.
  ///
  /// In fr, this message translates to:
  /// **'À ouvrir avec l\'app sur un autre téléphone'**
  String get shareFileHint;

  /// No description provided for @shareQrScanHint.
  ///
  /// In fr, this message translates to:
  /// **'Sur l\'autre téléphone : Importer, puis Scanner un QR code.'**
  String get shareQrScanHint;

  /// No description provided for @shareOtherWays.
  ///
  /// In fr, this message translates to:
  /// **'Autres façons de partager'**
  String get shareOtherWays;

  /// No description provided for @shareWhatLists.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 liste} other{{count} listes}}'**
  String shareWhatLists(int count);

  /// No description provided for @shareWhatCards.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 carte} other{{count} cartes}}'**
  String shareWhatCards(int count);

  /// No description provided for @shareWhatCategories.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 catégorie} other{{count} catégories}}'**
  String shareWhatCategories(int count);

  /// No description provided for @importTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get importTitle;

  /// No description provided for @importSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un QR code, un fichier ou un lien reçu'**
  String get importSubtitle;

  /// No description provided for @importScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un QR code'**
  String get importScan;

  /// No description provided for @importScanHint.
  ///
  /// In fr, this message translates to:
  /// **'Montré par l\'app sur un autre téléphone'**
  String get importScanHint;

  /// No description provided for @importFile.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir un fichier'**
  String get importFile;

  /// No description provided for @importFileHint.
  ///
  /// In fr, this message translates to:
  /// **'Une sauvegarde ou un fichier partagé'**
  String get importFileHint;

  /// No description provided for @importPaste.
  ///
  /// In fr, this message translates to:
  /// **'Coller un lien'**
  String get importPaste;

  /// No description provided for @importPasteHint.
  ///
  /// In fr, this message translates to:
  /// **'Un lien Shopping List copié'**
  String get importPasteHint;

  /// No description provided for @importEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'y a rien à importer.'**
  String get importEmpty;

  /// No description provided for @importDone.
  ///
  /// In fr, this message translates to:
  /// **'Importé'**
  String get importDone;

  /// No description provided for @importRestored.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde restaurée'**
  String get importRestored;

  /// No description provided for @importReceived.
  ///
  /// In fr, this message translates to:
  /// **'Données reçues'**
  String get importReceived;

  /// No description provided for @importBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get importBackup;

  /// No description provided for @importBackupOf.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde du {date} à {time}'**
  String importBackupOf(String date, String time);

  /// No description provided for @importAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get importAll;

  /// No description provided for @importNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get importNone;

  /// No description provided for @importAdd.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Rien de coché} =1{Ajouter 1 élément} other{Ajouter {count} éléments}}'**
  String importAdd(int count);

  /// No description provided for @importReplace.
  ///
  /// In fr, this message translates to:
  /// **'Tout remplacer par cette sauvegarde'**
  String get importReplace;

  /// No description provided for @importReplaceConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tes données actuelles seront remplacées. Une copie est gardée dans les points de restauration.'**
  String get importReplaceConfirm;

  /// No description provided for @importCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get importCategories;

  /// No description provided for @backupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Toutes tes données dans un seul fichier, montants compris'**
  String get backupSubtitle;

  /// No description provided for @backupSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une sauvegarde'**
  String get backupSend;

  /// No description provided for @backupSendHint.
  ///
  /// In fr, this message translates to:
  /// **'Vers Drive, un mail, une conversation…'**
  String get backupSendHint;

  /// No description provided for @backupSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer sur le téléphone'**
  String get backupSave;

  /// No description provided for @backupSaveHint.
  ///
  /// In fr, this message translates to:
  /// **'Dans le dossier de ton choix'**
  String get backupSaveHint;

  /// No description provided for @backupRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une sauvegarde'**
  String get backupRestore;

  /// No description provided for @backupRestoreHint.
  ///
  /// In fr, this message translates to:
  /// **'Tu verras son contenu avant de choisir'**
  String get backupRestoreHint;

  /// No description provided for @backupSaved.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde enregistrée'**
  String get backupSaved;

  /// No description provided for @restorePointsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Points de restauration'**
  String get restorePointsTitle;

  /// No description provided for @restorePointsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Des copies gardées sur le téléphone. Touche-en une pour revenir à ce moment-là.'**
  String get restorePointsSubtitle;

  /// No description provided for @restorePointsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune copie pour l\'instant : la première sera faite demain.'**
  String get restorePointsEmpty;

  /// No description provided for @restorePointDaily.
  ///
  /// In fr, this message translates to:
  /// **'Copie du jour'**
  String get restorePointDaily;

  /// No description provided for @restorePointBeforeImport.
  ///
  /// In fr, this message translates to:
  /// **'Avant un import'**
  String get restorePointBeforeImport;

  /// No description provided for @restorePointBeforeRestore.
  ///
  /// In fr, this message translates to:
  /// **'Avant une restauration'**
  String get restorePointBeforeRestore;

  /// No description provided for @restorePointConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Revenir aux données du {when} ? Les données actuelles sont gardées en copie.'**
  String restorePointConfirm(String when);

  /// No description provided for @restorePointRestore.
  ///
  /// In fr, this message translates to:
  /// **'Revenir à cette copie'**
  String get restorePointRestore;

  /// No description provided for @restorePointDone.
  ///
  /// In fr, this message translates to:
  /// **'Données restaurées'**
  String get restorePointDone;

  /// No description provided for @settingsItemsRestorePointsHint.
  ///
  /// In fr, this message translates to:
  /// **'Une copie automatique chaque jour'**
  String get settingsItemsRestorePointsHint;

  /// No description provided for @importReplaceConfirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer mes données'**
  String get importReplaceConfirmButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
