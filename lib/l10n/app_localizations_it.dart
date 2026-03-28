// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'CheckMake';

  @override
  String get appSubtitle => 'Crea l\'armata. Spezza la corona.';

  @override
  String get statCoins => 'Monete';

  @override
  String get statWins => 'Vittorie';

  @override
  String get statLosses => 'Sconfitte';

  @override
  String get statInitiative => 'Iniziativa';

  @override
  String get btnPlay => 'GIOCA IN LOCALE';

  @override
  String get btnMultiplayer => 'GIOCA ONLINE';

  @override
  String get btnBuildArmy => 'COSTRUISCI ESERCITO';

  @override
  String get btnShop => 'NEGOZIO';

  @override
  String get shopTitle => 'Negozio';

  @override
  String get shopTabPieces => 'Pezzi';

  @override
  String get shopTabUpgrades => 'Potenziamenti';

  @override
  String get shopTabSkins => 'Skin';

  @override
  String shopUnlockSuccess(String pieceName) {
    return '$pieceName sbloccato!';
  }

  @override
  String get shopUpgradePieces => 'Migliora i pezzi';

  @override
  String shopInitiativeLabel(int level) {
    return 'Iniziativa: Lvl $level';
  }

  @override
  String get shopInitiativeDesc =>
      'Chi ha iniziativa più alta inizia la partita. In caso di parità, si lancia una moneta.';

  @override
  String shopUpgradeBtn(int cost) {
    return 'Potenzia ($cost🪙)';
  }

  @override
  String get shopSkinForArmy => 'Skin per tutta l\'armata';

  @override
  String get shopEquip => 'Equipaggia';

  @override
  String get shopStatValue => '🪙 Valore';

  @override
  String get armyBuilderTitle => 'Costruisci Esercito';

  @override
  String get armySave => 'Salva';

  @override
  String get armySaved => 'Esercito salvato!';

  @override
  String get basePawn => 'Pedoni';

  @override
  String get baseRook => 'Torri';

  @override
  String get baseKnight => 'Cavalli';

  @override
  String get baseBishop => 'Alfieri';

  @override
  String get baseQueen => 'Regine';

  @override
  String get baseKing => 'Re';

  @override
  String get gameOpponentTurn => 'Turno avversario';

  @override
  String get gameModeLocal => 'Locale';

  @override
  String get gameModeOnline => 'Online';

  @override
  String get gameOver => 'Fine partita';

  @override
  String get gameLeaveConfirmTitle => 'Abbandonare la partita?';

  @override
  String get gameLeaveConfirmBody =>
      'Uscendo concederai la partita all\'avversario.';

  @override
  String get gameLeaveConfirmCancel => 'Annulla';

  @override
  String get gameLeaveConfirmOk => 'Abbandona';

  @override
  String get gameWinByForfeitTitle => 'Vittoria assegnata';

  @override
  String get gameWinByForfeitBody =>
      'L\'avversario ha abbandonato la partita. Hai vinto!';

  @override
  String get gameDialogClose => 'Chiudi';

  @override
  String get gameResultVictoryTitle => 'Vittoria!';

  @override
  String get gameResultVictoryBody => 'Hai vinto la partita online.';

  @override
  String get gameResultDefeatTitle => 'Sconfitta';

  @override
  String get gameResultDefeatBody => 'Hai perso la partita online.';

  @override
  String get gameResultAbandonedTitle => 'Partita abbandonata';

  @override
  String get gameResultAbandonedBody => 'Hai abbandonato la partita online.';

  @override
  String gameResultCoins(int coins) {
    return 'Monete guadagnate: +$coins';
  }

  @override
  String get gameTurnMoved =>
      'Hai mosso. Puoi usare un\'abilità o finire il turno.';

  @override
  String get gameTurnAbility =>
      'Abilità usata. Puoi muovere o finire il turno.';

  @override
  String get gameTurnSelect => '🎮 Il tuo turno';

  @override
  String get pieceNamePawn => 'Pedone';

  @override
  String get pieceDescPawn =>
      'Il soldato base, muove avanti e cattura in diagonale.';

  @override
  String get pieceNameRook => 'Torre';

  @override
  String get pieceDescRook => 'Muove in linea retta, alta resistenza.';

  @override
  String get pieceNameKnight => 'Cavallo';

  @override
  String get pieceDescKnight => 'Muove a L, può scavalcare i pezzi.';

  @override
  String get pieceNameBishop => 'Alfiere';

  @override
  String get pieceDescBishop => 'Muove in diagonale, velocità elevata.';

  @override
  String get pieceNameQueen => 'Regina';

  @override
  String get pieceDescQueen =>
      'Il pezzo più potente, muove in tutte le direzioni.';

  @override
  String get pieceNameKing => 'Re';

  @override
  String get pieceDescKing => 'Va protetto. La sua caduta significa sconfitta.';

  @override
  String get pieceNameFighter => 'Combattente';

  @override
  String get pieceDescFighter => 'Variante del pedone con attacco potenziato.';

  @override
  String get pieceNameMiner => 'Minatore';

  @override
  String get pieceDescMiner => 'Può piazzare trappole sul terreno.';

  @override
  String get pieceNameRifleman => 'Fuciliere';

  @override
  String get pieceDescRifleman => 'Attacca a distanza di 2 caselle.';

  @override
  String get pieceNameHealer => 'Curatore';

  @override
  String get pieceDescHealer => 'Può ripristinare HP a pezzi alleati.';

  @override
  String get pieceNameInvestigator => 'Investigatore';

  @override
  String get pieceDescInvestigator => 'Può rivelare le statistiche dei nemici.';

  @override
  String get pieceNameInvisibleMan => 'Uomo Invisibile';

  @override
  String get pieceDescInvisibleMan => 'Può rendersi invisibile per un turno.';

  @override
  String get pieceNameWarlord => 'Condottiera';

  @override
  String get pieceDescWarlord => 'Potenzia i pezzi alleati nelle vicinanze.';

  @override
  String get pieceNameHeartQueen => 'Regina di Cuori';

  @override
  String get pieceDescHeartQueen => 'Salute elevatissima, può rigenerare HP.';

  @override
  String get pieceNameSoulReaper => 'Rapitrice di Anime';

  @override
  String get pieceDescSoulReaper => 'Ruba HP dai nemici eliminati.';

  @override
  String get pieceNameCatapult => 'Catapulta';

  @override
  String get pieceDescCatapult => 'Alto attacco, può colpire a distanza.';

  @override
  String get pieceNameIronWall => 'Muro di Ferro';

  @override
  String get pieceDescIronWall => 'HP massivi, blocca il passaggio nemico.';

  @override
  String get pieceNamePaladin => 'Paladino';

  @override
  String get pieceDescPaladin => 'Equilibrio perfetto tra attacco e difesa.';

  @override
  String get pieceNameShadowRider => 'Cavaliere Ombra';

  @override
  String get pieceDescShadowRider =>
      'Si muove in silenzio, colpi critici frequenti.';

  @override
  String get pieceNameCommander => 'Comandante';

  @override
  String get pieceDescCommander =>
      'Un leader sul campo di battaglia che potenzia i pezzi alleati.';

  @override
  String get abilityNameBattleCry => 'Grido di Guerra';

  @override
  String get abilityDescBattleCry => 'Aumenta l\'attacco del 50% per un turno.';

  @override
  String get abilityNamePlaceTrap => 'Piazza Trappola';

  @override
  String get abilityDescPlaceTrap =>
      'Piazza una trappola su una casella adiacente.';

  @override
  String get abilityNameLongShot => 'Tiro Lungo';

  @override
  String get abilityDescLongShot => 'Attacca un pezzo a 3 caselle di distanza.';

  @override
  String get abilityNameHeal => 'Cura';

  @override
  String get abilityDescHeal =>
      'Ripristina 20 HP a un pezzo alleato adiacente.';

  @override
  String get abilityNameReveal => 'Analisi';

  @override
  String get abilityDescReveal =>
      'Rivela le statistiche di un pezzo nemico per 2 turni.';

  @override
  String get abilityNameInvisibility => 'Invisibilità';

  @override
  String get abilityDescInvisibility =>
      'Diventa invisibile al nemico per 1 turno.';

  @override
  String get abilityNameBattleCommand => 'Comando Bellico';

  @override
  String get abilityDescBattleCommand =>
      'Tutti i pezzi alleati nel raggio di 2 guadagnano +5 ATK per 2 turni.';

  @override
  String get abilityNameRoyalAura => 'Aura Regale';

  @override
  String get abilityDescRoyalAura =>
      'Rigenera 15 HP a tutti i pezzi alleati adiacenti.';

  @override
  String get abilityNameSoulSteal => 'Furto d\'Anima';

  @override
  String get abilityDescSoulSteal =>
      'Ruba il 30% degli HP massimi di un pezzo nemico adiacente.';

  @override
  String get abilityNameBombardment => 'Bombardamento';

  @override
  String get abilityDescBombardment =>
      'Attacca tutte le caselle in una riga o colonna.';

  @override
  String get abilityNameFortify => 'Fortifica';

  @override
  String get abilityDescFortify =>
      'Riduce i danni subiti del 50% fino al prossimo turno.';

  @override
  String get abilityNameHolyCharge => 'Carica Sacra';

  @override
  String get abilityDescHolyCharge =>
      'Si muove 2 volte questa mossa, infliggendo +10 danno.';

  @override
  String get abilityNameShadowStrike => 'Colpo d\'Ombra';

  @override
  String get abilityDescShadowStrike =>
      'Attacco garantito critico (danno raddoppiato).';

  @override
  String get abilityNameSpecial => 'Abilità speciale';

  @override
  String get skinFireArmy => 'Armata del Fuoco';

  @override
  String get skinFireArmyDesc => 'Tinge tutti i tuoi pezzi di rosso ardente';

  @override
  String get skinIceArmy => 'Armata del Ghiaccio';

  @override
  String get skinIceArmyDesc => 'Pezzi cristallizzati in blu glaciale';

  @override
  String get skinPawnShadow => 'Pedone Ombra';

  @override
  String get skinPawnShadowDesc => 'Skin oscura per i tuoi pedoni';

  @override
  String get skinQueenGolden => 'Regina Dorata';

  @override
  String get skinQueenGoldenDesc => 'La tua regina splende d\'oro';
}
