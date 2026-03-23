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
  String get appSubtitle => 'Battle Chess';

  @override
  String get statCoins => 'Monete';

  @override
  String get statWins => 'Vittorie';

  @override
  String get statLosses => 'Sconfitte';

  @override
  String get statInitiative => 'Iniziativa';

  @override
  String get btnPlay => 'GIOCA';

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
  String get gameEndTurn => 'Fine turno';

  @override
  String get gameOver => 'Fine partita';

  @override
  String get gameTurnMoved =>
      'Hai mosso. Puoi usare un\'abilità o finire il turno.';

  @override
  String get gameTurnAbility =>
      'Abilità usata. Puoi muovere o finire il turno.';

  @override
  String get gameTurnSelect => '🎮 Il tuo turno — seleziona un pezzo';

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
