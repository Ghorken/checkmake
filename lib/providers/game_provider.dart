// lib/providers/game_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/models/achievement.dart';
import 'package:checkmake/services/movement_service.dart';
import 'package:checkmake/services/combat_service.dart';

enum GamePhase { myTurn, opponentTurn, combat, gameOver, waitingForOpponent }

enum TurnAction { none, moved, usedAbility }

class GameProvider extends ChangeNotifier {
  static const int turnDurationSeconds = 30;

  late Board board;
  late PlayerProfile myProfile;
  late PlayerProfile opponentProfile; // in local multiplayer
  final bool hotseatMode;
  final bool trainingMode;

  // Stato interno della fase - la fase visibile è calcolata tramite il getter `phase`
  GamePhase _phaseRaw = GamePhase.myTurn;

  late PlayerSide currentTurn;
  Position? selectedPosition;
  List<Position> validMoves = [];
  Position? _abilitySourcePosition;
  List<Position> _abilityTargets = [];
  TurnAction turnAction = TurnAction.none;
  Timer? _turnTimer;
  Timer? _combatLogTimer;
  int _turnSecondsLeft = turnDurationSeconds;

  // Il lato che il giocatore locale controlla (player1 per partite locali,
  // sovrascrivibile per il multiplayer online)
  PlayerSide get localSide => PlayerSide.player1;

  bool get isLocalTurn => hotseatMode || currentTurn == localSide;
  PlayerSide get interactiveSide => hotseatMode ? currentTurn : localSide;

  /// La fase visualizzata nella UI: myTurn/opponentTurn sono calcolati in base
  /// a `localSide` così funzionano correttamente sia per player1 che player2.
  GamePhase get phase {
    if (_phaseRaw == GamePhase.gameOver ||
        _phaseRaw == GamePhase.waitingForOpponent) {
      return _phaseRaw;
    }
    return isLocalTurn ? GamePhase.myTurn : GamePhase.opponentTurn;
  }

  set phase(GamePhase p) {
    _phaseRaw = p;
    if (_phaseRaw == GamePhase.gameOver ||
        _phaseRaw == GamePhase.waitingForOpponent) {
      _stopTurnTimer();
    }
  }

  bool get canMove =>
      turnAction == TurnAction.none || turnAction == TurnAction.usedAbility;
  bool get canUseAbility =>
      turnAction == TurnAction.none || turnAction == TurnAction.moved;
  int get turnSecondsLeft => _turnSecondsLeft;
  bool get isAbilityTargeting => _abilitySourcePosition != null;
  bool isAbilitySource(Position pos) => _abilitySourcePosition == pos;

  String? lastCombatLog;
  int myCoinsEarned = 0;

  // Sprite animation state: set after combat, cleared after animation duration
  Position? lastAttackPos;
  Timer? _animClearTimer;
  int _hitSignalCounter = 0;
  final Map<Position, int> _hitSignals = {};

  int hitSignalFor(Position pos) => _hitSignals[pos] ?? 0;

  GameProvider({
    required this.myProfile,
    required this.opponentProfile,
    this.hotseatMode = false,
    this.trainingMode = false,
    PlayerSide initialTurn = PlayerSide.player1,
    bool startPaused = false,
    PlayerProfile? player1ProfileForBoard,
    PlayerProfile? player2ProfileForBoard,
  }) {
    currentTurn = initialTurn;
    _initBoard(
      player1Profile: player1ProfileForBoard ?? myProfile,
      player2Profile: player2ProfileForBoard ?? opponentProfile,
    );
    if (startPaused) {
      _phaseRaw = GamePhase.waitingForOpponent;
    } else {
      _startTurnTimer(notify: false);
    }
  }

  void startHotseatMatch(PlayerSide startingSide) {
    if ((!hotseatMode && !trainingMode) || _phaseRaw == GamePhase.gameOver) {
      return;
    }
    currentTurn = startingSide;
    _clearAbilityTargeting();
    selectedPosition = null;
    validMoves = [];
    turnAction = TurnAction.none;
    _phaseRaw = GamePhase.myTurn;
    _startTurnTimer(notify: false);
    notifyListeners();
  }

  void _initBoard({
    required PlayerProfile player1Profile,
    required PlayerProfile player2Profile,
  }) {
    board = Board();
    _setupArmy(player2Profile, PlayerSide.player2, isTop: true);
    _setupArmy(player1Profile, PlayerSide.player1, isTop: false);
  }

  void _setupArmy(PlayerProfile profile, PlayerSide side,
      {required bool isTop}) {
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

    final pawns = pieces
        .where((t) => pieceDefinitions[t]!.baseType == PieceBaseType.pawn)
        .toList();
    final backPieces = pieces
        .where((t) => pieceDefinitions[t]!.baseType != PieceBaseType.pawn)
        .toList();

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

  void _placePiece(
      PieceType type, Position pos, PlayerSide side, PlayerProfile profile) {
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
    if (!isLocalTurn) {
      return;
    }
    if (_phaseRaw == GamePhase.gameOver ||
        _phaseRaw == GamePhase.waitingForOpponent) {
      return;
    }

    if (isAbilityTargeting) {
      if (pos == _abilitySourcePosition) {
        _clearAbilityTargeting();
        selectedPosition = null;
        validMoves = [];
        notifyListeners();
        return;
      }
      if (_abilityTargets.contains(pos)) {
        _resolvePiercingShot(targetPos: pos);
        return;
      }
      _clearAbilityTargeting();
    }

    // Toggle selezione: tap sullo stesso pezzo già selezionato = deseleziona.
    if (selectedPosition == pos) {
      selectedPosition = null;
      validMoves = [];
      notifyListeners();
      return;
    }

    final piece = board.getPiece(pos);

    // Se ho già selezionato un pezzo e clicco su una mossa valida
    if (selectedPosition != null && validMoves.contains(pos)) {
      executeMove(selectedPosition!, pos);
      return;
    }

    // Seleziona il pezzo se è mio
    if (piece != null && piece.side == interactiveSide && canMove) {
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
    _clearAbilityTargeting();
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

      // In locale non si guadagnano monete.
      // Online e allenamento: guadagna monete solo quando è il turno del giocatore locale.
      if (!hotseatMode && attacker.side == localSide) {
        myCoinsEarned += result.coinsEarned;
        myProfile.addCoins(result.coinsEarned);
      }

      board.setPiece(from, null);
      board.setPiece(to, null);

      if (result.survivingDefender != null) {
        board.setPiece(result.defenderNewPosition!, result.survivingDefender);
      }
      if (result.survivingAttacker != null) {
        board.setPiece(result.attackerNewPosition!, result.survivingAttacker);
      }

      _showCombatLog(_buildCombatLog(attacker, defender, result));
      _triggerCombatAnimation(from);
      final hitPositions = <Position>[];
      if (result.survivingDefender != null &&
          result.defenderNewPosition != null) {
        hitPositions.add(result.defenderNewPosition!);
      }
      _emitHitSignals(hitPositions);
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
    } else if (result.survivingAttacker != null &&
        result.survivingDefender == null) {
      final baseMessage =
          '${pieceDefinitions[attacker.type]!.displayName} ha eliminato '
          '${pieceDefinitions[defender.type]!.displayName}!';
      if (hotseatMode) {
        return baseMessage;
      }
      return '$baseMessage +${result.coinsEarned} monete';
    } else if (result.survivingAttacker == null) {
      return '${pieceDefinitions[defender.type]!.displayName} ha respinto l\'attacco!';
    } else {
      return 'Scontro! Entrambi i pezzi sopravvivono.';
    }
  }

  void _showCombatLog(String message) {
    _combatLogTimer?.cancel();
    lastCombatLog = message;
    _combatLogTimer = Timer(const Duration(seconds: 3), () {
      lastCombatLog = null;
      notifyListeners();
    });
  }

  void _triggerCombatAnimation(Position attackerPos) {
    _animClearTimer?.cancel();
    lastAttackPos = attackerPos;
    _animClearTimer = Timer(const Duration(milliseconds: 600), () {
      lastAttackPos = null;
      notifyListeners();
    });
  }

  void _emitHitSignals(Iterable<Position> positions) {
    for (final pos in positions.toSet()) {
      _hitSignals[pos] = ++_hitSignalCounter;
    }
  }

  void useAbility(Position piecePos) {
    if (!canUseAbility) return;

    if (_abilitySourcePosition == piecePos) {
      _clearAbilityTargeting();
      selectedPosition = null;
      validMoves = [];
      notifyListeners();
      return;
    }
    _clearAbilityTargeting();

    final piece = board.getPiece(piecePos);
    if (piece == null || piece.side != interactiveSide) return;
    final ability = piece.specialAbility;
    if (ability == null || ability.isPassive || !ability.isReady) return;

    switch (ability.activeEffect) {
      case ActiveEffect.heal:
        final healAmount = (piece.stats.maxHp * ability.activeValue).round();
        final newHp =
            (piece.stats.currentHp + healAmount).clamp(0, piece.stats.maxHp);
        board.setPiece(
          piecePos,
          piece.copyWith(stats: piece.stats.copyWith(currentHp: newHp)),
        );
        _showCombatLog(
            '+$healAmount HP per ${pieceDefinitions[piece.type]!.displayName}');
      case ActiveEffect.piercingShot:
        final targets = _piercingShotTargets(piecePos, piece.side);
        if (targets.isEmpty) {
          _showCombatLog('Nessun bersaglio in linea per la Ballista.');
          notifyListeners();
          return;
        }
        _abilitySourcePosition = piecePos;
        _abilityTargets = targets;
        selectedPosition = piecePos;
        validMoves = List<Position>.from(targets);
        notifyListeners();
        return;
      case null:
        break;
    }

    ability.currentCooldown = ability.cooldown;
    turnAction = TurnAction.usedAbility;
    notifyListeners();
  }

  void endTurn() {
    if (!isLocalTurn) return;
    _checkEndTurn();
  }

  void _checkEndTurn() {
    _clearAbilityTargeting();
    selectedPosition = null;
    validMoves = [];
    turnAction = TurnAction.none;

    if (_phaseRaw == GamePhase.gameOver ||
        _phaseRaw == GamePhase.waitingForOpponent) {
      _stopTurnTimer();
      notifyListeners();
      return;
    }

    // Decrementa i cooldown dei pezzi del giocatore corrente
    _tickCooldowns(currentTurn);

    currentTurn = currentTurn == PlayerSide.player1
        ? PlayerSide.player2
        : PlayerSide.player1;
    _startTurnTimer(notify: false);
    // La fase viene calcolata automaticamente dal getter `phase` tramite `isLocalTurn`
    notifyListeners();
  }

  void _checkGameOver() {
    final oppSide = localSide == PlayerSide.player1
        ? PlayerSide.player2
        : PlayerSide.player1;
    final myKing = board.findKing(localSide);
    final oppKing = board.findKing(oppSide);

    if (myKing == null) {
      _phaseRaw = GamePhase.gameOver;
      if (!hotseatMode && !trainingMode) {
        myProfile.registerLoss(coinsReward: 10);
        tryUnlockAchievements(myProfile);
      } else if (trainingMode) {
        myProfile.addCoins(10);
      }
    } else if (oppKing == null) {
      _phaseRaw = GamePhase.gameOver;
      if (!hotseatMode && !trainingMode) {
        myProfile.registerWin(coinsReward: 200);
        tryUnlockAchievements(myProfile);
      } else if (trainingMode) {
        myProfile.addCoins(200);
      }
    }
  }

  void _startTurnTimer({bool notify = true}) {
    _stopTurnTimer();
    _turnSecondsLeft = turnDurationSeconds;

    if (_phaseRaw == GamePhase.gameOver ||
        _phaseRaw == GamePhase.waitingForOpponent) {
      return;
    }

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phaseRaw == GamePhase.gameOver ||
          _phaseRaw == GamePhase.waitingForOpponent) {
        timer.cancel();
        return;
      }

      if (_turnSecondsLeft > 0) {
        _turnSecondsLeft--;
      }

      if (_turnSecondsLeft == 0) {
        timer.cancel();
        _handleTurnTimeout();
        return;
      }

      notifyListeners();
    });

    if (notify) {
      notifyListeners();
    }
  }

  void _stopTurnTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  void _stopCombatLogTimer() {
    _combatLogTimer?.cancel();
    _combatLogTimer = null;
  }

  void _tickCooldowns(PlayerSide side) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPiece(Position(row, col));
        if (piece?.side == side) {
          final ability = piece!.specialAbility;
          if (ability != null &&
              !ability.isPassive &&
              ability.currentCooldown > 0) {
            ability.currentCooldown--;
          }
        }
      }
    }
  }

  void _handleTurnTimeout() {
    if (_phaseRaw == GamePhase.gameOver ||
        _phaseRaw == GamePhase.waitingForOpponent) {
      return;
    }
    _clearAbilityTargeting();
    _checkEndTurn();
  }

  void _clearAbilityTargeting() {
    _abilitySourcePosition = null;
    _abilityTargets = [];
  }

  List<Position> _piercingShotTargets(Position from, PlayerSide side) {
    const directions = [
      Position(1, 0),
      Position(-1, 0),
      Position(0, 1),
      Position(0, -1),
    ];
    final targets = <Position>[];
    for (final dir in directions) {
      var pos = from + dir;
      while (pos.isValid) {
        final piece = board.getPiece(pos);
        if (piece != null && piece.side != side) {
          targets.add(pos);
        }
        pos = pos + dir;
      }
    }
    return targets;
  }

  void _resolvePiercingShot({required Position targetPos}) {
    final sourcePos = _abilitySourcePosition;
    if (sourcePos == null) return;

    final attacker = board.getPiece(sourcePos);
    if (attacker == null || attacker.side != interactiveSide) {
      _clearAbilityTargeting();
      selectedPosition = null;
      validMoves = [];
      notifyListeners();
      return;
    }

    final ability = attacker.specialAbility;
    if (ability == null ||
        ability.isPassive ||
        ability.activeEffect != ActiveEffect.piercingShot ||
        !ability.isReady) {
      _clearAbilityTargeting();
      selectedPosition = null;
      validMoves = [];
      notifyListeners();
      return;
    }

    final defender = board.getPiece(targetPos);
    if (defender == null || defender.side == attacker.side) {
      _clearAbilityTargeting();
      selectedPosition = null;
      validMoves = [];
      notifyListeners();
      return;
    }

    final damage = (attacker.stats.attack * ability.activeValue).round();
    final newHp = defender.stats.currentHp - damage;
    if (newHp <= 0) {
      board.setPiece(targetPos, null);
      if (!hotseatMode && attacker.side == localSide) {
        myCoinsEarned += defender.stats.value;
        myProfile.addCoins(defender.stats.value);
      }
      _showCombatLog(
        '${pieceDefinitions[attacker.type]!.displayName} abbatte ${pieceDefinitions[defender.type]!.displayName} con una freccia perforante!',
      );
    } else {
      board.setPiece(
        targetPos,
        defender.copyWith(
          stats: defender.stats.copyWith(currentHp: newHp),
        ),
      );
      _emitHitSignals([targetPos]);
      _showCombatLog(
        '${pieceDefinitions[attacker.type]!.displayName} colpisce ${pieceDefinitions[defender.type]!.displayName} (-$damage HP).',
      );
    }

    ability.currentCooldown = ability.cooldown;
    turnAction = TurnAction.usedAbility;
    _clearAbilityTargeting();
    selectedPosition = null;
    validMoves = [];
    _checkGameOver();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTurnTimer();
    _stopCombatLogTimer();
    _animClearTimer?.cancel();
    super.dispose();
  }
}
