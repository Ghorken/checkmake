// lib/providers/game_provider.dart

import 'package:flutter/foundation.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/services/movement_service.dart';
import 'package:checkmake/services/combat_service.dart';

enum GamePhase { myTurn, opponentTurn, combat, gameOver, waitingForOpponent }

enum TurnAction { none, moved, usedAbility }

class GameProvider extends ChangeNotifier {
  late Board board;
  late PlayerProfile myProfile;
  late PlayerProfile opponentProfile; // in local multiplayer

  // Stato interno della fase - la fase visibile è calcolata tramite il getter `phase`
  GamePhase _phaseRaw = GamePhase.myTurn;

  PlayerSide currentTurn = PlayerSide.player1;
  Position? selectedPosition;
  List<Position> validMoves = [];
  TurnAction turnAction = TurnAction.none;

  // Il lato che il giocatore locale controlla (player1 per partite locali,
  // sovrascrivibile per il multiplayer online)
  PlayerSide get localSide => PlayerSide.player1;

  bool get isLocalTurn => currentTurn == localSide;

  /// La fase visualizzata nella UI: myTurn/opponentTurn sono calcolati in base
  /// a `localSide` così funzionano correttamente sia per player1 che player2.
  GamePhase get phase {
    if (_phaseRaw == GamePhase.gameOver || _phaseRaw == GamePhase.waitingForOpponent) {
      return _phaseRaw;
    }
    return isLocalTurn ? GamePhase.myTurn : GamePhase.opponentTurn;
  }

  set phase(GamePhase p) => _phaseRaw = p;

  bool get canMove => turnAction == TurnAction.none || turnAction == TurnAction.usedAbility;
  bool get canUseAbility => turnAction == TurnAction.none || turnAction == TurnAction.moved;

  String? lastCombatLog;
  int myCoinsEarned = 0;

  GameProvider({required this.myProfile, required this.opponentProfile}) {
    _initBoard();
  }

  void _initBoard() {
    board = Board();
    _setupArmy(opponentProfile, PlayerSide.player2, isTop: true);
    _setupArmy(myProfile, PlayerSide.player1, isTop: false);
  }

  void _setupArmy(PlayerProfile profile, PlayerSide side, {required bool isTop}) {
    final config = profile.armyConfig;
    final pieces = <PieceType>[];
    config.composition.forEach((type, count) {
      for (int i = 0; i < count; i++) {
        pieces.add(type);
      }
    });

    // Posizionamento semplificato: pedoni in riga 2, resto in riga 1 (o specchiato)
    final pawnRow = isTop ? 1 : 6;
    final backRow = isTop ? 0 : 7;

    final pawns = pieces.where((t) => pieceDefinitions[t]!.baseType == PieceBaseType.pawn).toList();
    final backPieces = pieces.where((t) => pieceDefinitions[t]!.baseType != PieceBaseType.pawn).toList();

    for (int i = 0; i < pawns.length && i < 8; i++) {
      _placePiece(pawns[i], Position(pawnRow, i), side, profile);
    }

    // Ordine standard: torre, cavallo, alfiere, regina, re, alfiere, cavallo, torre
    final backOrder = [
      PieceBaseType.rook,
      PieceBaseType.knight,
      PieceBaseType.bishop,
      PieceBaseType.queen,
      PieceBaseType.king,
      PieceBaseType.bishop,
      PieceBaseType.knight,
      PieceBaseType.rook
    ];

    int backIdx = 0;
    for (final baseType in backOrder) {
      final match = backPieces.firstWhere(
        (t) => pieceDefinitions[t]!.baseType == baseType,
        orElse: () => _defaultForBase(baseType),
      );
      if (backIdx < 8) {
        _placePiece(match, Position(backRow, backIdx), side, profile);
        backPieces.remove(match);
        backIdx++;
      }
    }
  }

  PieceType _defaultForBase(PieceBaseType base) => switch (base) {
        PieceBaseType.pawn => PieceType.pawn,
        PieceBaseType.rook => PieceType.rook,
        PieceBaseType.knight => PieceType.knight,
        PieceBaseType.bishop => PieceType.bishop,
        PieceBaseType.queen => PieceType.queen,
        PieceBaseType.king => PieceType.king,
      };

  void _placePiece(PieceType type, Position pos, PlayerSide side, PlayerProfile profile) {
    final def = pieceDefinitions[type]!;
    final stats = profile.getStatsForPiece(type);
    final piece = Piece(
      id: '${side.name}_${type.name}_${pos.row}_${pos.col}',
      type: type,
      baseType: def.baseType,
      side: side,
      stats: stats,
      specialAbility: def.abilityFactory?.call(),
    );
    board.setPiece(pos, piece);
  }

  void selectPosition(Position pos) {
    if (!isLocalTurn) return;
    if (_phaseRaw == GamePhase.gameOver || _phaseRaw == GamePhase.waitingForOpponent) return;

    final piece = board.getPiece(pos);

    // Se ho già selezionato un pezzo e clicco su una mossa valida
    if (selectedPosition != null && validMoves.contains(pos)) {
      executeMove(selectedPosition!, pos);
      return;
    }

    // Seleziona il pezzo se è mio
    if (piece != null && piece.side == localSide && canMove) {
      selectedPosition = pos;
      validMoves = MovementService.getValidMoves(board, pos);
    } else {
      selectedPosition = null;
      validMoves = [];
    }
    notifyListeners();
  }

  /// Esegue una mossa (pubblica per permettere la sovrascrittura nel multiplayer online).
  void executeMove(Position from, Position to) {
    final attacker = board.getPiece(from);
    if (attacker == null) return;
    final defender = board.getPiece(to);

    if (defender != null && defender.side != attacker.side) {
      // COMBATTIMENTO
      final result = CombatService.resolveCombat(
        attacker: attacker,
        defender: defender,
        attackerPos: from,
        defenderPos: to,
        board: board,
      );

      // Guadagna monete solo quando è il turno del giocatore locale
      if (attacker.side == localSide) {
        myCoinsEarned += result.coinsEarned;
        myProfile.coins += result.coinsEarned;
      }

      board.setPiece(from, null);
      board.setPiece(to, null);

      if (result.survivingDefender != null) {
        board.setPiece(to, result.survivingDefender);
      }
      if (result.survivingAttacker != null && result.attackerNewPosition != null) {
        board.setPiece(result.attackerNewPosition!, result.survivingAttacker);
      }

      lastCombatLog = _buildCombatLog(attacker, defender, result);
    } else {
      // SPOSTAMENTO SEMPLICE
      board.movePiece(from, to);
      final movedPiece = board.getPiece(to);
      if (movedPiece != null) {
        board.setPiece(to, movedPiece.copyWith(hasMoved: true));
      }
    }

    selectedPosition = null;
    validMoves = [];
    turnAction = TurnAction.moved;

    // Controlla vittoria
    _checkGameOver();

    // Se il turno è completato (mossa + abilità usata o solo mossa)
    if (turnAction == TurnAction.moved) {
      _checkEndTurn();
    }

    notifyListeners();
  }

  String _buildCombatLog(Piece attacker, Piece defender, CombatResult result) {
    if (result.survivingAttacker == null && result.survivingDefender == null) {
      return 'Entrambi i pezzi si sono eliminati!';
    } else if (result.survivingAttacker != null && result.survivingDefender == null) {
      return '${pieceDefinitions[attacker.type]!.displayName} ha eliminato '
          '${pieceDefinitions[defender.type]!.displayName}! +${result.coinsEarned} monete';
    } else if (result.survivingAttacker == null) {
      return '${pieceDefinitions[defender.type]!.displayName} ha respinto l\'attacco!';
    } else {
      return 'Scontro! Entrambi i pezzi sopravvivono.';
    }
  }

  void useAbility(Position piecePos) {
    if (!canUseAbility) return;
    final piece = board.getPiece(piecePos);
    if (piece == null || piece.side != localSide) return;
    if (piece.specialAbility == null || !piece.specialAbility!.isReady) return;

    // TODO: implementare effetti delle abilità specifiche
    // Per ora segnala solo che è stata usata
    turnAction = TurnAction.usedAbility;
    notifyListeners();
  }

  void endTurn() {
    if (!isLocalTurn) return;
    _checkEndTurn();
  }

  void _checkEndTurn() {
    turnAction = TurnAction.none;
    currentTurn = currentTurn == PlayerSide.player1 ? PlayerSide.player2 : PlayerSide.player1;
    // La fase viene calcolata automaticamente dal getter `phase` tramite `isLocalTurn`
    notifyListeners();
  }

  void _checkGameOver() {
    final oppSide = localSide == PlayerSide.player1 ? PlayerSide.player2 : PlayerSide.player1;
    final myKing = board.findKing(localSide);
    final oppKing = board.findKing(oppSide);

    if (myKing == null) {
      _phaseRaw = GamePhase.gameOver;
      myProfile.losses++;
      myProfile.coins += 10; // premio piccolo per la sconfitta
    } else if (oppKing == null) {
      _phaseRaw = GamePhase.gameOver;
      myProfile.wins++;
      myProfile.coins += 200; // premio vittoria
    }
  }
}
