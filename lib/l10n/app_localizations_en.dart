// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CheckMake';

  @override
  String get appSubtitle => 'Build your army. Break the king.';

  @override
  String get statCoins => 'Coins';

  @override
  String get statWins => 'Wins';

  @override
  String get statLosses => 'Losses';

  @override
  String get statInitiative => 'Initiative';

  @override
  String get btnPlay => 'PLAY';

  @override
  String get btnBuildArmy => 'BUILD ARMY';

  @override
  String get btnShop => 'SHOP';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopTabPieces => 'Pieces';

  @override
  String get shopTabUpgrades => 'Upgrades';

  @override
  String get shopTabSkins => 'Skins';

  @override
  String shopUnlockSuccess(String pieceName) {
    return '$pieceName unlocked!';
  }

  @override
  String get shopUpgradePieces => 'Upgrade pieces';

  @override
  String shopInitiativeLabel(int level) {
    return 'Initiative: Lvl $level';
  }

  @override
  String get shopInitiativeDesc =>
      'The player with higher initiative goes first. On a tie, a coin is flipped.';

  @override
  String shopUpgradeBtn(int cost) {
    return 'Upgrade ($cost🪙)';
  }

  @override
  String get shopSkinForArmy => 'Skin for the whole army';

  @override
  String get shopEquip => 'Equip';

  @override
  String get shopStatValue => '🪙 Value';

  @override
  String get armyBuilderTitle => 'Build Army';

  @override
  String get armySave => 'Save';

  @override
  String get armySaved => 'Army saved!';

  @override
  String get basePawn => 'Pawns';

  @override
  String get baseRook => 'Rooks';

  @override
  String get baseKnight => 'Knights';

  @override
  String get baseBishop => 'Bishops';

  @override
  String get baseQueen => 'Queens';

  @override
  String get baseKing => 'Kings';

  @override
  String get gameOpponentTurn => 'Opponent\'s turn';

  @override
  String get gameEndTurn => 'End turn';

  @override
  String get gameOver => 'End game';

  @override
  String get gameTurnMoved =>
      'You moved. You can use an ability or end your turn.';

  @override
  String get gameTurnAbility => 'Ability used. You can move or end your turn.';

  @override
  String get gameTurnSelect => '🎮 Your turn — select a piece';

  @override
  String get pieceNamePawn => 'Pawn';

  @override
  String get pieceDescPawn =>
      'The basic soldier, moves forward and captures diagonally.';

  @override
  String get pieceNameRook => 'Rook';

  @override
  String get pieceDescRook => 'Moves in straight lines, high durability.';

  @override
  String get pieceNameKnight => 'Knight';

  @override
  String get pieceDescKnight => 'Moves in an L-shape, can jump over pieces.';

  @override
  String get pieceNameBishop => 'Bishop';

  @override
  String get pieceDescBishop => 'Moves diagonally, high speed.';

  @override
  String get pieceNameQueen => 'Queen';

  @override
  String get pieceDescQueen =>
      'The most powerful piece, moves in all directions.';

  @override
  String get pieceNameKing => 'King';

  @override
  String get pieceDescKing => 'Must be protected. Its fall means defeat.';

  @override
  String get abilityNameSpecial => 'Special ability';

  @override
  String get skinFireArmy => 'Fire Army';

  @override
  String get skinFireArmyDesc => 'Dyes all your pieces in blazing red';

  @override
  String get skinIceArmy => 'Ice Army';

  @override
  String get skinIceArmyDesc => 'Pieces crystallized in glacial blue';

  @override
  String get skinPawnShadow => 'Shadow Pawn';

  @override
  String get skinPawnShadowDesc => 'Dark skin for your pawns';

  @override
  String get skinQueenGolden => 'Golden Queen';

  @override
  String get skinQueenGoldenDesc => 'Your queen shines in gold';
}
