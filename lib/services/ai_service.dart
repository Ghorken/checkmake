// lib/services/ai_service.dart
// Logica dell'avversario IA per la modalità Allenamento

import 'dart:math' as math;

import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/services/movement_service.dart';

class _AiMove {
  final Position from;
  final Position to;
  final double score;
  _AiMove(this.from, this.to, this.score);
}

class AIService {
  /// Restituisce la mossa migliore per il lato IA, o null se non ci sono mosse.
  static ({Position from, Position to})? getBestMove(
      Board board, PlayerSide aiSide) {
    final candidates = <_AiMove>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final pos = Position(row, col);
        final piece = board.getPiece(pos);
        if (piece == null || piece.side != aiSide) continue;

        final moves = MovementService.getValidMoves(board, pos);
        for (final target in moves) {
          final score = _scoreMove(board, pos, target, piece, aiSide);
          candidates.add(_AiMove(pos, target, score));
        }
      }
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.score.compareTo(a.score));

    // Sceglie casualmente tra le mosse con punteggio uguale (o quasi) al top
    final topScore = candidates.first.score;
    final topMoves =
        candidates.where((m) => m.score >= topScore - 0.01).toList();

    final rng = math.Random();
    final chosen = topMoves[rng.nextInt(topMoves.length)];
    return (from: chosen.from, to: chosen.to);
  }

  static double _scoreMove(
    Board board,
    Position from,
    Position to,
    Piece attacker,
    PlayerSide aiSide,
  ) {
    final defender = board.getPiece(to);

    if (defender != null) {
      final defNewHp = defender.stats.currentHp - attacker.stats.attack;
      final atkNewHp = attacker.stats.currentHp - defender.stats.attack;

      final defenderDied = defNewHp <= 0;
      final attackerDied = atkNewHp <= 0;

      // Catturare il re = vittoria immediata
      if (defenderDied && defender.baseType == PieceBaseType.king) {
        return 100000;
      }

      if (!attackerDied && defenderDied) {
        // Cattura favorevole: guadagno il valore del pezzo nemico
        return 5000 + defender.stats.value * 10.0;
      } else if (attackerDied && !defenderDied) {
        // Perdo il pezzo: molto negativo
        return -attacker.stats.value * 10.0;
      } else if (attackerDied && defenderDied) {
        // Entrambi muoiono: neutro, dipende dai valori
        return (defender.stats.value - attacker.stats.value) * 5.0;
      } else {
        // Entrambi sopravvivono: leggermente positivo (infliggo danni)
        return defender.stats.value * 2.0;
      }
    }

    // Casella vuota: bonus avanzamento verso il nemico
    final advancement =
        aiSide == PlayerSide.player2 ? to.row : (7 - to.row);
    return advancement * 0.5;
  }
}
