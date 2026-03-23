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
  String get btnMultiplayer => 'MULTIPLAYER';

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
  String get pieceNameFighter => 'Fighter';

  @override
  String get pieceDescFighter => 'A pawn variant with boosted attack.';

  @override
  String get pieceNameMiner => 'Miner';

  @override
  String get pieceDescMiner => 'Can place traps on the ground.';

  @override
  String get pieceNameRifleman => 'Rifleman';

  @override
  String get pieceDescRifleman => 'Attacks from 2 squares away.';

  @override
  String get pieceNameHealer => 'Healer';

  @override
  String get pieceDescHealer => 'Can restore HP to allied pieces.';

  @override
  String get pieceNameInvestigator => 'Investigator';

  @override
  String get pieceDescInvestigator => 'Can reveal enemy statistics.';

  @override
  String get pieceNameInvisibleMan => 'Invisible Man';

  @override
  String get pieceDescInvisibleMan => 'Can become invisible for one turn.';

  @override
  String get pieceNameWarlord => 'Warlord';

  @override
  String get pieceDescWarlord => 'Boosts nearby allied pieces.';

  @override
  String get pieceNameHeartQueen => 'Heart Queen';

  @override
  String get pieceDescHeartQueen => 'Extremely high health, can regenerate HP.';

  @override
  String get pieceNameSoulReaper => 'Soul Reaper';

  @override
  String get pieceDescSoulReaper => 'Steals HP from eliminated enemies.';

  @override
  String get pieceNameCatapult => 'Catapult';

  @override
  String get pieceDescCatapult => 'High attack, can strike from a distance.';

  @override
  String get pieceNameIronWall => 'Iron Wall';

  @override
  String get pieceDescIronWall => 'Massive HP, blocks enemy movement.';

  @override
  String get pieceNamePaladin => 'Paladin';

  @override
  String get pieceDescPaladin => 'Perfect balance between attack and defense.';

  @override
  String get pieceNameShadowRider => 'Shadow Rider';

  @override
  String get pieceDescShadowRider => 'Moves silently, frequent critical hits.';

  @override
  String get pieceNameCommander => 'Commander';

  @override
  String get pieceDescCommander =>
      'A battlefield leader that boosts allied pieces.';

  @override
  String get abilityNameBattleCry => 'Battle Cry';

  @override
  String get abilityDescBattleCry => 'Increases attack by 50% for one turn.';

  @override
  String get abilityNamePlaceTrap => 'Place Trap';

  @override
  String get abilityDescPlaceTrap => 'Places a trap on an adjacent square.';

  @override
  String get abilityNameLongShot => 'Long Shot';

  @override
  String get abilityDescLongShot => 'Attacks a piece 3 squares away.';

  @override
  String get abilityNameHeal => 'Heal';

  @override
  String get abilityDescHeal => 'Restores 20 HP to an adjacent allied piece.';

  @override
  String get abilityNameReveal => 'Analysis';

  @override
  String get abilityDescReveal =>
      'Reveals an enemy piece\'s stats for 2 turns.';

  @override
  String get abilityNameInvisibility => 'Invisibility';

  @override
  String get abilityDescInvisibility =>
      'Becomes invisible to the enemy for 1 turn.';

  @override
  String get abilityNameBattleCommand => 'Battle Command';

  @override
  String get abilityDescBattleCommand =>
      'All allied pieces within range 2 gain +5 ATK for 2 turns.';

  @override
  String get abilityNameRoyalAura => 'Royal Aura';

  @override
  String get abilityDescRoyalAura =>
      'Regenerates 15 HP to all adjacent allied pieces.';

  @override
  String get abilityNameSoulSteal => 'Soul Steal';

  @override
  String get abilityDescSoulSteal =>
      'Steals 30% of an adjacent enemy piece\'s max HP.';

  @override
  String get abilityNameBombardment => 'Bombardment';

  @override
  String get abilityDescBombardment =>
      'Attacks all squares in a row or column.';

  @override
  String get abilityNameFortify => 'Fortify';

  @override
  String get abilityDescFortify =>
      'Reduces damage taken by 50% until next turn.';

  @override
  String get abilityNameHolyCharge => 'Holy Charge';

  @override
  String get abilityDescHolyCharge =>
      'Moves twice this turn, dealing +10 damage.';

  @override
  String get abilityNameShadowStrike => 'Shadow Strike';

  @override
  String get abilityDescShadowStrike =>
      'Guaranteed critical hit (double damage).';

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
