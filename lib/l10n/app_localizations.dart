import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('it')
  ];

  /// Nome dell'app
  ///
  /// In it, this message translates to:
  /// **'Crown Fall'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Battle Chess'**
  String get appSubtitle;

  /// No description provided for @statCoins.
  ///
  /// In it, this message translates to:
  /// **'Monete'**
  String get statCoins;

  /// No description provided for @statWins.
  ///
  /// In it, this message translates to:
  /// **'Vittorie'**
  String get statWins;

  /// No description provided for @statLosses.
  ///
  /// In it, this message translates to:
  /// **'Sconfitte'**
  String get statLosses;

  /// No description provided for @statInitiative.
  ///
  /// In it, this message translates to:
  /// **'Iniziativa'**
  String get statInitiative;

  /// No description provided for @btnPlay.
  ///
  /// In it, this message translates to:
  /// **'GIOCA'**
  String get btnPlay;

  /// No description provided for @btnBuildArmy.
  ///
  /// In it, this message translates to:
  /// **'COSTRUISCI ESERCITO'**
  String get btnBuildArmy;

  /// No description provided for @btnShop.
  ///
  /// In it, this message translates to:
  /// **'NEGOZIO'**
  String get btnShop;

  /// No description provided for @shopTitle.
  ///
  /// In it, this message translates to:
  /// **'Negozio'**
  String get shopTitle;

  /// No description provided for @shopTabPieces.
  ///
  /// In it, this message translates to:
  /// **'Pezzi'**
  String get shopTabPieces;

  /// No description provided for @shopTabUpgrades.
  ///
  /// In it, this message translates to:
  /// **'Potenziamenti'**
  String get shopTabUpgrades;

  /// No description provided for @shopTabSkins.
  ///
  /// In it, this message translates to:
  /// **'Skin'**
  String get shopTabSkins;

  /// No description provided for @shopUnlockSuccess.
  ///
  /// In it, this message translates to:
  /// **'{pieceName} sbloccato!'**
  String shopUnlockSuccess(String pieceName);

  /// No description provided for @shopUpgradePieces.
  ///
  /// In it, this message translates to:
  /// **'Migliora i pezzi'**
  String get shopUpgradePieces;

  /// No description provided for @shopInitiativeLabel.
  ///
  /// In it, this message translates to:
  /// **'Iniziativa: Lvl {level}'**
  String shopInitiativeLabel(int level);

  /// No description provided for @shopInitiativeDesc.
  ///
  /// In it, this message translates to:
  /// **'Chi ha iniziativa più alta inizia la partita. In caso di parità, si lancia una moneta.'**
  String get shopInitiativeDesc;

  /// No description provided for @shopUpgradeBtn.
  ///
  /// In it, this message translates to:
  /// **'Potenzia ({cost}🪙)'**
  String shopUpgradeBtn(int cost);

  /// No description provided for @shopSkinForArmy.
  ///
  /// In it, this message translates to:
  /// **'Skin per tutta l\'armata'**
  String get shopSkinForArmy;

  /// No description provided for @shopEquip.
  ///
  /// In it, this message translates to:
  /// **'Equipaggia'**
  String get shopEquip;

  /// No description provided for @shopStatValue.
  ///
  /// In it, this message translates to:
  /// **'🪙 Valore'**
  String get shopStatValue;

  /// No description provided for @armyBuilderTitle.
  ///
  /// In it, this message translates to:
  /// **'Costruisci Esercito'**
  String get armyBuilderTitle;

  /// No description provided for @armySave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get armySave;

  /// No description provided for @armySaved.
  ///
  /// In it, this message translates to:
  /// **'Esercito salvato!'**
  String get armySaved;

  /// No description provided for @basePawn.
  ///
  /// In it, this message translates to:
  /// **'Pedoni'**
  String get basePawn;

  /// No description provided for @baseRook.
  ///
  /// In it, this message translates to:
  /// **'Torri'**
  String get baseRook;

  /// No description provided for @baseKnight.
  ///
  /// In it, this message translates to:
  /// **'Cavalli'**
  String get baseKnight;

  /// No description provided for @baseBishop.
  ///
  /// In it, this message translates to:
  /// **'Alfieri'**
  String get baseBishop;

  /// No description provided for @baseQueen.
  ///
  /// In it, this message translates to:
  /// **'Regine'**
  String get baseQueen;

  /// No description provided for @baseKing.
  ///
  /// In it, this message translates to:
  /// **'Re'**
  String get baseKing;

  /// No description provided for @gameOpponentTurn.
  ///
  /// In it, this message translates to:
  /// **'Turno avversario'**
  String get gameOpponentTurn;

  /// No description provided for @gameEndTurn.
  ///
  /// In it, this message translates to:
  /// **'Fine turno'**
  String get gameEndTurn;

  /// No description provided for @gameOver.
  ///
  /// In it, this message translates to:
  /// **'Fine partita'**
  String get gameOver;

  /// No description provided for @gameTurnMoved.
  ///
  /// In it, this message translates to:
  /// **'Hai mosso. Puoi usare un\'abilità o finire il turno.'**
  String get gameTurnMoved;

  /// No description provided for @gameTurnAbility.
  ///
  /// In it, this message translates to:
  /// **'Abilità usata. Puoi muovere o finire il turno.'**
  String get gameTurnAbility;

  /// No description provided for @gameTurnSelect.
  ///
  /// In it, this message translates to:
  /// **'🎮 Il tuo turno — seleziona un pezzo'**
  String get gameTurnSelect;

  /// No description provided for @pieceNamePawn.
  ///
  /// In it, this message translates to:
  /// **'Pedone'**
  String get pieceNamePawn;

  /// No description provided for @pieceDescPawn.
  ///
  /// In it, this message translates to:
  /// **'Il soldato base, muove avanti e cattura in diagonale.'**
  String get pieceDescPawn;

  /// No description provided for @pieceNameRook.
  ///
  /// In it, this message translates to:
  /// **'Torre'**
  String get pieceNameRook;

  /// No description provided for @pieceDescRook.
  ///
  /// In it, this message translates to:
  /// **'Muove in linea retta, alta resistenza.'**
  String get pieceDescRook;

  /// No description provided for @pieceNameKnight.
  ///
  /// In it, this message translates to:
  /// **'Cavallo'**
  String get pieceNameKnight;

  /// No description provided for @pieceDescKnight.
  ///
  /// In it, this message translates to:
  /// **'Muove a L, può scavalcare i pezzi.'**
  String get pieceDescKnight;

  /// No description provided for @pieceNameBishop.
  ///
  /// In it, this message translates to:
  /// **'Alfiere'**
  String get pieceNameBishop;

  /// No description provided for @pieceDescBishop.
  ///
  /// In it, this message translates to:
  /// **'Muove in diagonale, velocità elevata.'**
  String get pieceDescBishop;

  /// No description provided for @pieceNameQueen.
  ///
  /// In it, this message translates to:
  /// **'Regina'**
  String get pieceNameQueen;

  /// No description provided for @pieceDescQueen.
  ///
  /// In it, this message translates to:
  /// **'Il pezzo più potente, muove in tutte le direzioni.'**
  String get pieceDescQueen;

  /// No description provided for @pieceNameKing.
  ///
  /// In it, this message translates to:
  /// **'Re'**
  String get pieceNameKing;

  /// No description provided for @pieceDescKing.
  ///
  /// In it, this message translates to:
  /// **'Va protetto. La sua caduta significa sconfitta.'**
  String get pieceDescKing;

  /// No description provided for @abilityNameSpecial.
  ///
  /// In it, this message translates to:
  /// **'Abilità speciale'**
  String get abilityNameSpecial;

  /// No description provided for @skinFireArmy.
  ///
  /// In it, this message translates to:
  /// **'Armata del Fuoco'**
  String get skinFireArmy;

  /// No description provided for @skinFireArmyDesc.
  ///
  /// In it, this message translates to:
  /// **'Tinge tutti i tuoi pezzi di rosso ardente'**
  String get skinFireArmyDesc;

  /// No description provided for @skinIceArmy.
  ///
  /// In it, this message translates to:
  /// **'Armata del Ghiaccio'**
  String get skinIceArmy;

  /// No description provided for @skinIceArmyDesc.
  ///
  /// In it, this message translates to:
  /// **'Pezzi cristallizzati in blu glaciale'**
  String get skinIceArmyDesc;

  /// No description provided for @skinPawnShadow.
  ///
  /// In it, this message translates to:
  /// **'Pedone Ombra'**
  String get skinPawnShadow;

  /// No description provided for @skinPawnShadowDesc.
  ///
  /// In it, this message translates to:
  /// **'Skin oscura per i tuoi pedoni'**
  String get skinPawnShadowDesc;

  /// No description provided for @skinQueenGolden.
  ///
  /// In it, this message translates to:
  /// **'Regina Dorata'**
  String get skinQueenGolden;

  /// No description provided for @skinQueenGoldenDesc.
  ///
  /// In it, this message translates to:
  /// **'La tua regina splende d\'oro'**
  String get skinQueenGoldenDesc;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
