// lib/services/combat_service.dart

import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';

class CombatService {
  /// Gestisce lo scontro tra attaccante e difensore.
  /// Restituisce il risultato del combattimento.
  static CombatResult resolveCombat({
    required Piece attacker,
    required Piece defender,
    required Position attackerPos,
    required Position defenderPos,
    required Board board,
  }) {
    // Fase 1: scambio simultaneo
    int defenderNewHp = defender.stats.currentHp - attacker.stats.attack;
    int attackerNewHp = attacker.stats.currentHp - defender.stats.attack;

    // Fase 2: secondo attacco del Combattente (se sopravvive al primo scambio)
    if (attacker.type == PieceType.fighter &&
        attackerNewHp > 0 &&
        defenderNewHp > 0) {
      defenderNewHp -= attacker.stats.attack;
    }
    if (defender.type == PieceType.fighter &&
        defenderNewHp > 0 &&
        attackerNewHp > 0) {
      attackerNewHp -= defender.stats.attack;
    }

    final attackerDied = attackerNewHp <= 0;
    final defenderDied = defenderNewHp <= 0;

    Piece? survivingAttacker;
    Piece? survivingDefender;
    int coinsEarned = 0;
    Position? attackerNewPos;
    Position? defenderNewPos;

    if (!attackerDied) {
      survivingAttacker = attacker.copyWith(
        stats: attacker.stats.copyWith(
          currentHp: attackerNewHp.clamp(0, attacker.stats.maxHp),
        ),
      );
    }

    if (!defenderDied) {
      survivingDefender = defender.copyWith(
        stats: defender.stats.copyWith(
          currentHp: defenderNewHp.clamp(0, defender.stats.maxHp),
        ),
      );
    } else {
      coinsEarned += defender.stats.value;
    }

    if (defenderDied && !attackerDied) {
      // Attaccante avanza
      attackerNewPos = defenderPos;
    } else if (attackerDied && !defenderDied) {
      // Difensore avanza
      defenderNewPos = attackerPos;
    } else if (!attackerDied && !defenderDied) {
      // Entrambi sopravvivono: attaccante torna indietro
      final path = _getPathPositions(attackerPos, defenderPos);
      // cerca la casella libera più vicina lungo il percorso
      Position? fallback;
      for (int i = path.length - 2; i >= 0; i--) {
        if (board.getPiece(path[i]) == null) {
          fallback = path[i];
          break;
        }
      }
      attackerNewPos = fallback ?? attackerPos;
      defenderNewPos = defenderPos;
    }

    return CombatResult(
      survivingAttacker: survivingAttacker,
      survivingDefender: survivingDefender,
      coinsEarned: coinsEarned,
      attackerNewPosition: attackerNewPos,
      defenderNewPosition: defenderNewPos,
    );
  }

  static List<Position> _getPathPositions(Position from, Position to) {
    final rowDiff = (to.row - from.row).abs();
    final colDiff = (to.col - from.col).abs();
    final isLinearPath =
        from.row == to.row || from.col == to.col || rowDiff == colDiff;
    if (!isLinearPath) {
      // Es. cavallo: non esiste un percorso "a step costante" da attraversare.
      return [to];
    }

    final positions = <Position>[];
    final dr = (to.row - from.row).sign;
    final dc = (to.col - from.col).sign;
    var pos = Position(from.row + dr, from.col + dc);
    while (pos.row != to.row || pos.col != to.col) {
      positions.add(pos);
      pos = Position(pos.row + dr, pos.col + dc);
    }
    positions.add(to);
    return positions;
  }
}
