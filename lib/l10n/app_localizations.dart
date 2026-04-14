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

  /// Crea l'armata. Spezza la corona.
  ///
  /// In it, this message translates to:
  /// **'CheckMake'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Crea l\'armata. Spezza la corona.'**
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
  /// **'GIOCA IN LOCALE'**
  String get btnPlay;

  /// No description provided for @btnMultiplayer.
  ///
  /// In it, this message translates to:
  /// **'GIOCA ONLINE'**
  String get btnMultiplayer;

  /// No description provided for @btnTraining.
  ///
  /// In it, this message translates to:
  /// **'ALLENAMENTO'**
  String get btnTraining;

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

  /// No description provided for @gameModeLocal.
  ///
  /// In it, this message translates to:
  /// **'Locale'**
  String get gameModeLocal;

  /// No description provided for @gameModeOnline.
  ///
  /// In it, this message translates to:
  /// **'Online'**
  String get gameModeOnline;

  /// No description provided for @gameOver.
  ///
  /// In it, this message translates to:
  /// **'Fine partita'**
  String get gameOver;

  /// No description provided for @gameLeaveConfirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Abbandonare la partita?'**
  String get gameLeaveConfirmTitle;

  /// No description provided for @gameLeaveConfirmBody.
  ///
  /// In it, this message translates to:
  /// **'Uscendo concederai la partita all\'avversario.'**
  String get gameLeaveConfirmBody;

  /// No description provided for @gameLeaveConfirmCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get gameLeaveConfirmCancel;

  /// No description provided for @gameLeaveConfirmOk.
  ///
  /// In it, this message translates to:
  /// **'Abbandona'**
  String get gameLeaveConfirmOk;

  /// No description provided for @gameWinByForfeitTitle.
  ///
  /// In it, this message translates to:
  /// **'Vittoria assegnata'**
  String get gameWinByForfeitTitle;

  /// No description provided for @gameWinByForfeitBody.
  ///
  /// In it, this message translates to:
  /// **'L\'avversario ha abbandonato la partita. Hai vinto!'**
  String get gameWinByForfeitBody;

  /// No description provided for @gameDialogClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get gameDialogClose;

  /// No description provided for @gameResultVictoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Vittoria!'**
  String get gameResultVictoryTitle;

  /// No description provided for @gameResultVictoryBody.
  ///
  /// In it, this message translates to:
  /// **'Hai vinto la partita online.'**
  String get gameResultVictoryBody;

  /// No description provided for @gameResultDefeatTitle.
  ///
  /// In it, this message translates to:
  /// **'Sconfitta'**
  String get gameResultDefeatTitle;

  /// No description provided for @gameResultDefeatBody.
  ///
  /// In it, this message translates to:
  /// **'Hai perso la partita online.'**
  String get gameResultDefeatBody;

  /// No description provided for @gameResultTrainingVictoryBody.
  ///
  /// In it, this message translates to:
  /// **'Hai vinto la partita allenamento.'**
  String get gameResultTrainingVictoryBody;

  /// No description provided for @gameResultTrainingDefeatBody.
  ///
  /// In it, this message translates to:
  /// **'Hai perso la partita allenamento.'**
  String get gameResultTrainingDefeatBody;

  /// No description provided for @gameResultAbandonedTitle.
  ///
  /// In it, this message translates to:
  /// **'Partita abbandonata'**
  String get gameResultAbandonedTitle;

  /// No description provided for @gameResultAbandonedBody.
  ///
  /// In it, this message translates to:
  /// **'Hai abbandonato la partita online.'**
  String get gameResultAbandonedBody;

  /// No description provided for @gameResultCoins.
  ///
  /// In it, this message translates to:
  /// **'Monete guadagnate: +{coins}'**
  String gameResultCoins(int coins);

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
  /// **'🎮 Il tuo turno'**
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

  /// No description provided for @pieceNameFighter.
  ///
  /// In it, this message translates to:
  /// **'Combattente'**
  String get pieceNameFighter;

  /// No description provided for @pieceDescFighter.
  ///
  /// In it, this message translates to:
  /// **'Variante del pedone con attacco potenziato.'**
  String get pieceDescFighter;

  /// No description provided for @pieceNameBalista.
  ///
  /// In it, this message translates to:
  /// **'Ballista'**
  String get pieceNameBalista;

  /// No description provided for @pieceDescBalista.
  ///
  /// In it, this message translates to:
  /// **'Muove e attacca come una torre. Può sparare attraverso i pezzi.'**
  String get pieceDescBalista;

  /// No description provided for @pieceNameMiner.
  ///
  /// In it, this message translates to:
  /// **'Minatore'**
  String get pieceNameMiner;

  /// No description provided for @pieceDescMiner.
  ///
  /// In it, this message translates to:
  /// **'Può piazzare trappole sul terreno.'**
  String get pieceDescMiner;

  /// No description provided for @pieceNameRifleman.
  ///
  /// In it, this message translates to:
  /// **'Fuciliere'**
  String get pieceNameRifleman;

  /// No description provided for @pieceDescRifleman.
  ///
  /// In it, this message translates to:
  /// **'Attacca a distanza di 2 caselle.'**
  String get pieceDescRifleman;

  /// No description provided for @pieceNameHealer.
  ///
  /// In it, this message translates to:
  /// **'Curatore'**
  String get pieceNameHealer;

  /// No description provided for @pieceDescHealer.
  ///
  /// In it, this message translates to:
  /// **'Può ripristinare HP a pezzi alleati.'**
  String get pieceDescHealer;

  /// No description provided for @pieceNameInvestigator.
  ///
  /// In it, this message translates to:
  /// **'Investigatore'**
  String get pieceNameInvestigator;

  /// No description provided for @pieceDescInvestigator.
  ///
  /// In it, this message translates to:
  /// **'Può rivelare le statistiche dei nemici.'**
  String get pieceDescInvestigator;

  /// No description provided for @pieceNameInvisibleMan.
  ///
  /// In it, this message translates to:
  /// **'Uomo Invisibile'**
  String get pieceNameInvisibleMan;

  /// No description provided for @pieceDescInvisibleMan.
  ///
  /// In it, this message translates to:
  /// **'Può rendersi invisibile per un turno.'**
  String get pieceDescInvisibleMan;

  /// No description provided for @pieceNameWarlord.
  ///
  /// In it, this message translates to:
  /// **'Condottiera'**
  String get pieceNameWarlord;

  /// No description provided for @pieceDescWarlord.
  ///
  /// In it, this message translates to:
  /// **'Potenzia i pezzi alleati nelle vicinanze.'**
  String get pieceDescWarlord;

  /// No description provided for @pieceNameHeartQueen.
  ///
  /// In it, this message translates to:
  /// **'Regina di Cuori'**
  String get pieceNameHeartQueen;

  /// No description provided for @pieceDescHeartQueen.
  ///
  /// In it, this message translates to:
  /// **'Salute elevatissima, può rigenerare HP.'**
  String get pieceDescHeartQueen;

  /// No description provided for @pieceNameSoulReaper.
  ///
  /// In it, this message translates to:
  /// **'Rapitrice di Anime'**
  String get pieceNameSoulReaper;

  /// No description provided for @pieceDescSoulReaper.
  ///
  /// In it, this message translates to:
  /// **'Ruba HP dai nemici eliminati.'**
  String get pieceDescSoulReaper;

  /// No description provided for @pieceNameCatapult.
  ///
  /// In it, this message translates to:
  /// **'Catapulta'**
  String get pieceNameCatapult;

  /// No description provided for @pieceDescCatapult.
  ///
  /// In it, this message translates to:
  /// **'Alto attacco, può colpire a distanza.'**
  String get pieceDescCatapult;

  /// No description provided for @pieceNameIronWall.
  ///
  /// In it, this message translates to:
  /// **'Muro di Ferro'**
  String get pieceNameIronWall;

  /// No description provided for @pieceDescIronWall.
  ///
  /// In it, this message translates to:
  /// **'HP massivi, blocca il passaggio nemico.'**
  String get pieceDescIronWall;

  /// No description provided for @pieceNamePaladin.
  ///
  /// In it, this message translates to:
  /// **'Paladino'**
  String get pieceNamePaladin;

  /// No description provided for @pieceDescPaladin.
  ///
  /// In it, this message translates to:
  /// **'Equilibrio perfetto tra attacco e difesa.'**
  String get pieceDescPaladin;

  /// No description provided for @pieceNameShadowRider.
  ///
  /// In it, this message translates to:
  /// **'Cavaliere Ombra'**
  String get pieceNameShadowRider;

  /// No description provided for @pieceDescShadowRider.
  ///
  /// In it, this message translates to:
  /// **'Si muove in silenzio, colpi critici frequenti.'**
  String get pieceDescShadowRider;

  /// No description provided for @pieceNameCommander.
  ///
  /// In it, this message translates to:
  /// **'Comandante'**
  String get pieceNameCommander;

  /// No description provided for @pieceDescCommander.
  ///
  /// In it, this message translates to:
  /// **'Un leader sul campo di battaglia che potenzia i pezzi alleati.'**
  String get pieceDescCommander;

  /// No description provided for @abilityNameBattleCry.
  ///
  /// In it, this message translates to:
  /// **'Grido di Guerra'**
  String get abilityNameBattleCry;

  /// No description provided for @abilityDescBattleCry.
  ///
  /// In it, this message translates to:
  /// **'Aumenta l\'attacco del 50% per un turno.'**
  String get abilityDescBattleCry;

  /// No description provided for @abilityNamePlaceTrap.
  ///
  /// In it, this message translates to:
  /// **'Piazza Trappola'**
  String get abilityNamePlaceTrap;

  /// No description provided for @abilityDescPlaceTrap.
  ///
  /// In it, this message translates to:
  /// **'Piazza una trappola su una casella adiacente.'**
  String get abilityDescPlaceTrap;

  /// No description provided for @abilityNameLongShot.
  ///
  /// In it, this message translates to:
  /// **'Tiro Lungo'**
  String get abilityNameLongShot;

  /// No description provided for @abilityDescLongShot.
  ///
  /// In it, this message translates to:
  /// **'Attacca un pezzo a 3 caselle di distanza.'**
  String get abilityDescLongShot;

  /// No description provided for @abilityNameHeal.
  ///
  /// In it, this message translates to:
  /// **'Cura'**
  String get abilityNameHeal;

  /// No description provided for @abilityDescHeal.
  ///
  /// In it, this message translates to:
  /// **'Ripristina 20 HP a un pezzo alleato adiacente.'**
  String get abilityDescHeal;

  /// No description provided for @abilityNameReveal.
  ///
  /// In it, this message translates to:
  /// **'Analisi'**
  String get abilityNameReveal;

  /// No description provided for @abilityDescReveal.
  ///
  /// In it, this message translates to:
  /// **'Rivela le statistiche di un pezzo nemico per 2 turni.'**
  String get abilityDescReveal;

  /// No description provided for @abilityNameInvisibility.
  ///
  /// In it, this message translates to:
  /// **'Invisibilità'**
  String get abilityNameInvisibility;

  /// No description provided for @abilityDescInvisibility.
  ///
  /// In it, this message translates to:
  /// **'Diventa invisibile al nemico per 1 turno.'**
  String get abilityDescInvisibility;

  /// No description provided for @abilityNameBattleCommand.
  ///
  /// In it, this message translates to:
  /// **'Comando Bellico'**
  String get abilityNameBattleCommand;

  /// No description provided for @abilityDescBattleCommand.
  ///
  /// In it, this message translates to:
  /// **'Tutti i pezzi alleati nel raggio di 2 guadagnano +5 ATK per 2 turni.'**
  String get abilityDescBattleCommand;

  /// No description provided for @abilityNameRoyalAura.
  ///
  /// In it, this message translates to:
  /// **'Aura Regale'**
  String get abilityNameRoyalAura;

  /// No description provided for @abilityDescRoyalAura.
  ///
  /// In it, this message translates to:
  /// **'Rigenera 15 HP a tutti i pezzi alleati adiacenti.'**
  String get abilityDescRoyalAura;

  /// No description provided for @abilityNameSoulSteal.
  ///
  /// In it, this message translates to:
  /// **'Furto d\'Anima'**
  String get abilityNameSoulSteal;

  /// No description provided for @abilityDescSoulSteal.
  ///
  /// In it, this message translates to:
  /// **'Ruba il 30% degli HP massimi di un pezzo nemico adiacente.'**
  String get abilityDescSoulSteal;

  /// No description provided for @abilityNameBombardment.
  ///
  /// In it, this message translates to:
  /// **'Bombardamento'**
  String get abilityNameBombardment;

  /// No description provided for @abilityDescBombardment.
  ///
  /// In it, this message translates to:
  /// **'Attacca tutte le caselle in una riga o colonna.'**
  String get abilityDescBombardment;

  /// No description provided for @abilityNameFortify.
  ///
  /// In it, this message translates to:
  /// **'Fortifica'**
  String get abilityNameFortify;

  /// No description provided for @abilityDescFortify.
  ///
  /// In it, this message translates to:
  /// **'Riduce i danni subiti del 50% fino al prossimo turno.'**
  String get abilityDescFortify;

  /// No description provided for @abilityNameDoubleAttack.
  ///
  /// In it, this message translates to:
  /// **'Doppio Attacco'**
  String get abilityNameDoubleAttack;

  /// No description provided for @abilityDescDoubleAttack.
  ///
  /// In it, this message translates to:
  /// **'Se sopravvive allo scontro, colpisce subito una seconda volta senza subire contrattacco.'**
  String get abilityDescDoubleAttack;

  /// No description provided for @abilityNamePiercingShot.
  ///
  /// In it, this message translates to:
  /// **'Freccia Perforante'**
  String get abilityNamePiercingShot;

  /// No description provided for @abilityDescPiercingShot.
  ///
  /// In it, this message translates to:
  /// **'Colpisce un nemico sulla stessa riga o colonna ignorando i pezzi intermedi.'**
  String get abilityDescPiercingShot;

  /// No description provided for @abilityNameHolyCharge.
  ///
  /// In it, this message translates to:
  /// **'Carica Sacra'**
  String get abilityNameHolyCharge;

  /// No description provided for @abilityDescHolyCharge.
  ///
  /// In it, this message translates to:
  /// **'Si muove 2 volte questa mossa, infliggendo +10 danno.'**
  String get abilityDescHolyCharge;

  /// No description provided for @abilityNameShadowStrike.
  ///
  /// In it, this message translates to:
  /// **'Colpo d\'Ombra'**
  String get abilityNameShadowStrike;

  /// No description provided for @abilityDescShadowStrike.
  ///
  /// In it, this message translates to:
  /// **'Attacco garantito critico (danno raddoppiato).'**
  String get abilityDescShadowStrike;

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

  /// No description provided for @btnLeaderboard.
  ///
  /// In it, this message translates to:
  /// **'Classifiche'**
  String get btnLeaderboard;

  /// No description provided for @btnAchievements.
  ///
  /// In it, this message translates to:
  /// **'Imprese'**
  String get btnAchievements;

  /// No description provided for @btnTutorial.
  ///
  /// In it, this message translates to:
  /// **'Tutorial'**
  String get btnTutorial;

  /// No description provided for @btnStats.
  ///
  /// In it, this message translates to:
  /// **'Statistiche'**
  String get btnStats;

  /// No description provided for @btnInfo.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get btnInfo;

  /// No description provided for @player2Name.
  ///
  /// In it, this message translates to:
  /// **'Giocatore 2'**
  String get player2Name;

  /// No description provided for @aiOpponentName.
  ///
  /// In it, this message translates to:
  /// **'Avversario IA'**
  String get aiOpponentName;

  /// No description provided for @infoTitle.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get infoTitle;

  /// No description provided for @bugRequestTitle.
  ///
  /// In it, this message translates to:
  /// **'Segnala un bug o suggerisci una feature'**
  String get bugRequestTitle;

  /// No description provided for @joinDiscordTitle.
  ///
  /// In it, this message translates to:
  /// **'Unisciti al nostro Discord'**
  String get joinDiscordTitle;

  /// No description provided for @sendEmailTitle.
  ///
  /// In it, this message translates to:
  /// **'Scrivici un\'email'**
  String get sendEmailTitle;

  /// No description provided for @supportEmail.
  ///
  /// In it, this message translates to:
  /// **'smithingthings@gmail.com'**
  String get supportEmail;

  /// No description provided for @supportSubject.
  ///
  /// In it, this message translates to:
  /// **'Supporto CheckMake'**
  String get supportSubject;

  /// No description provided for @privacyTitle.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla Privacy'**
  String get privacyTitle;

  /// No description provided for @discordUrl.
  ///
  /// In it, this message translates to:
  /// **'https://discord.gg/checkmake'**
  String get discordUrl;

  /// No description provided for @urlError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire {url}'**
  String urlError(String url);
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
