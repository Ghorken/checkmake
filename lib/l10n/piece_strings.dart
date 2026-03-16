// lib/l10n/piece_strings.dart
// Helper per recuperare nomi e descrizioni localizzati di pezzi, abilità e skin.

import 'package:flutter/material.dart';
import 'package:crownfall/models/piece.dart';
import 'package:crownfall/l10n/app_localizations.dart';

extension PieceStrings on AppLocalizations {
  // ===== NOMI PEZZI =====
  String pieceNameFor(PieceType type) => switch (type) {
        PieceType.pawn => pieceNamePawn,
        PieceType.rook => pieceNameRook,
        PieceType.knight => pieceNameKnight,
        PieceType.bishop => pieceNameBishop,
        PieceType.queen => pieceNameQueen,
        PieceType.king => pieceNameKing,
        PieceType.fighter => pieceNameFighter,
        PieceType.miner => pieceNameMiner,
        PieceType.rifleman => pieceNameRifleman,
        PieceType.healer => pieceNameHealer,
        PieceType.investigator => pieceNameInvestigator,
        PieceType.invisibleMan => pieceNameInvisibleMan,
        PieceType.warlord => pieceNameWarlord,
        PieceType.heartQueen => pieceNameHeartQueen,
        PieceType.soulReaper => pieceNameSoulReaper,
        PieceType.catapult => pieceNameCatapult,
        PieceType.ironWall => pieceNameIronWall,
        PieceType.paladin => pieceNamePaladin,
        PieceType.shadowRider => pieceNameShadowRider,
        PieceType.commander => pieceNameCommander,
      };

  // ===== DESCRIZIONI PEZZI =====
  String pieceDescFor(PieceType type) => switch (type) {
        PieceType.pawn => pieceDescPawn,
        PieceType.rook => pieceDescRook,
        PieceType.knight => pieceDescKnight,
        PieceType.bishop => pieceDescBishop,
        PieceType.queen => pieceDescQueen,
        PieceType.king => pieceDescKing,
        PieceType.fighter => pieceDescFighter,
        PieceType.miner => pieceDescMiner,
        PieceType.rifleman => pieceDescRifleman,
        PieceType.healer => pieceDescHealer,
        PieceType.investigator => pieceDescInvestigator,
        PieceType.invisibleMan => pieceDescInvisibleMan,
        PieceType.warlord => pieceDescWarlord,
        PieceType.heartQueen => pieceDescHeartQueen,
        PieceType.soulReaper => pieceDescSoulReaper,
        PieceType.catapult => pieceDescCatapult,
        PieceType.ironWall => pieceDescIronWall,
        PieceType.paladin => pieceDescPaladin,
        PieceType.shadowRider => pieceDescShadowRider,
        PieceType.commander => pieceDescCommander,
      };

  // ===== NOMI ABILITÀ =====
  String abilityNameFor(String abilityId) => switch (abilityId) {
        'battle_cry' => abilityNameBattleCry,
        'place_trap' => abilityNamePlaceTrap,
        'long_shot' => abilityNameLongShot,
        'heal' => abilityNameHeal,
        'reveal' => abilityNameReveal,
        'invisibility' => abilityNameInvisibility,
        'battle_command' => abilityNameBattleCommand,
        'royal_aura' => abilityNameRoyalAura,
        'soul_steal' => abilityNameSoulSteal,
        'bombardment' => abilityNameBombardment,
        'fortify' => abilityNameFortify,
        'holy_charge' => abilityNameHolyCharge,
        'shadow_strike' => abilityNameShadowStrike,
        _ => abilityId,
      };

  // ===== DESCRIZIONI ABILITÀ =====
  String abilityDescFor(String abilityId) => switch (abilityId) {
        'battle_cry' => abilityDescBattleCry,
        'place_trap' => abilityDescPlaceTrap,
        'long_shot' => abilityDescLongShot,
        'heal' => abilityDescHeal,
        'reveal' => abilityDescReveal,
        'invisibility' => abilityDescInvisibility,
        'battle_command' => abilityDescBattleCommand,
        'royal_aura' => abilityDescRoyalAura,
        'soul_steal' => abilityDescSoulSteal,
        'bombardment' => abilityDescBombardment,
        'fortify' => abilityDescFortify,
        'holy_charge' => abilityDescHolyCharge,
        'shadow_strike' => abilityDescShadowStrike,
        _ => abilityId,
      };

  // ===== LABEL TIPO BASE =====
  String baseTypeLabel(PieceBaseType base) => switch (base) {
        PieceBaseType.pawn => basePawn,
        PieceBaseType.rook => baseRook,
        PieceBaseType.knight => baseKnight,
        PieceBaseType.bishop => baseBishop,
        PieceBaseType.queen => baseQueen,
        PieceBaseType.king => baseKing,
      };
}

/// Shortcut per ottenere AppLocalizations dal context.
AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context)!;
