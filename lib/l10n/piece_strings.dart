// lib/l10n/piece_strings.dart
// Helper per recuperare nomi e descrizioni localizzati di pezzi, abilità e skin.

import 'package:flutter/material.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/l10n/app_localizations.dart';

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
      };

  // ===== NOMI ABILITÀ =====
  String abilityNameFor(String abilityId) => abilityId;

  // ===== DESCRIZIONI ABILITÀ =====
  String abilityDescFor(String abilityId) => abilityId;

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
