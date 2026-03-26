// lib/providers/online_game_provider.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/services/firebase_service.dart';

enum OnlineMatchOutcome { victory, defeat, abandoned }

/// Provider per il multiplayer online via Firebase.
///
/// Estende [GameProvider] aggiungendo:
///   - sincronizzazione delle mosse tramite Firestore
///   - gestione del lato locale (player1 o player2)
///   - notifica al server in caso di vittoria/sconfitta
class OnlineGameProvider extends GameProvider {
  final PlayerSide _mySide;
  final String gameCode;

  StreamSubscription<DocumentSnapshot>? _gameSubscription;

  /// Indice dell'ultima mossa applicata localmente (evita di riapplicare due volte).
  int _lastAppliedMoveIndex = -1;

  /// True mentre si sta applicando una mossa remota (evita loop infiniti).
  bool _applyingRemote = false;
  bool _resultApplied = false;
  bool _showEndDialog = false;
  OnlineMatchOutcome? _endDialogOutcome;
  bool _isDisposed = false;

  OnlineGameProvider({
    required super.myProfile,
    required super.opponentProfile,
    required PlayerSide mySide,
    required this.gameCode,
    required PlayerSide startingSide,
  })  : _mySide = mySide,
        super(initialTurn: startingSide) {
    _listenToGame();
  }

  @override
  PlayerSide get localSide => _mySide;

  bool get showEndDialog => _showEndDialog;
  OnlineMatchOutcome? get endDialogOutcome => _endDialogOutcome;

  void consumeEndDialog() {
    _showEndDialog = false;
    _endDialogOutcome = null;
  }

  // ── Override executeMove: invia la mossa a Firebase se è locale ───────────

  @override
  void executeMove(Position from, Position to) {
    final movingSide = currentTurn;
    super.executeMove(from, to);

    if (phase == GamePhase.gameOver && !_showEndDialog) {
      final myKingAlive = board.findKing(localSide) != null;
      _showEndDialog = true;
      _endDialogOutcome =
          myKingAlive ? OnlineMatchOutcome.victory : OnlineMatchOutcome.defeat;
    }

    // Invia a Firebase solo se non stiamo applicando una mossa remota
    if (!_applyingRemote) {
      unawaited(_syncMoveToServer(from, to, movingSide));
    }
  }

  Future<void> _syncMoveToServer(
    Position from,
    Position to,
    PlayerSide movingSide,
  ) async {
    try {
      await FirebaseService.sendMove(
          gameCode, from.row, from.col, to.row, to.col);
    } catch (e, st) {
      debugPrint('OnlineGameProvider.sendMove error: $e\n$st');
      return;
    }

    if (phase != GamePhase.gameOver) return;

    final winner = movingSide == PlayerSide.player1 ? 'player1' : 'player2';
    try {
      await FirebaseService.setWinner(gameCode, winner);
    } catch (e, st) {
      debugPrint('OnlineGameProvider.setWinner error: $e\n$st');
    }
  }

  // ── Listener Firestore ────────────────────────────────────────────────────

  void _listenToGame() {
    _gameSubscription = FirebaseService.watchGame(gameCode).listen((snap) {
      if (_isDisposed) return;
      if (!snap.exists) {
        // Se il documento viene rimosso, consideriamo la partita chiusa lato server.
        if (phase != GamePhase.gameOver && !_resultApplied) {
          _applyWinResult();
          _showEndDialog = true;
          _endDialogOutcome = OnlineMatchOutcome.victory;
          phase = GamePhase.gameOver;
          _safeNotifyListeners();
        }
        return;
      }
      final data = snap.data() as Map<String, dynamic>;

      _handleGameUpdate(data);
    });
  }

  void _handleGameUpdate(Map<String, dynamic> data) {
    // Partita terminata da remoto (es. avversario ha abbandonato)
    final serverWinner = data['winner'] as String?;
    final serverStatus = data['status'] as String?;
    if (serverStatus == 'finished' &&
        serverWinner != null &&
        phase != GamePhase.gameOver) {
      phase = GamePhase.gameOver;
      final mySideStr = _mySide == PlayerSide.player1 ? 'player1' : 'player2';
      if (serverWinner == mySideStr) {
        _applyWinResult();
        _showEndDialog = true;
        _endDialogOutcome = OnlineMatchOutcome.victory;
      } else {
        _applyLossResult();
        _showEndDialog = true;
        _endDialogOutcome = OnlineMatchOutcome.defeat;
      }
      _safeNotifyListeners();
      return;
    }

    // Nuova mossa dell'avversario
    final lastMoveData = data['lastMove'] as Map<String, dynamic>?;
    if (lastMoveData == null) return;

    final moveIndex = lastMoveData['moveIndex'] as int;
    if (moveIndex <= _lastAppliedMoveIndex) return;

    // Ignora l'eco della mossa appena inviata da questo stesso client.
    final movedBy = lastMoveData['movedBy'] as String?;
    if (movedBy != null && movedBy == FirebaseService.currentUserId) {
      _lastAppliedMoveIndex = moveIndex;
      return;
    }

    final from = Position(
      lastMoveData['fromRow'] as int,
      lastMoveData['fromCol'] as int,
    );
    final to = Position(
      lastMoveData['toRow'] as int,
      lastMoveData['toCol'] as int,
    );

    // Protezione extra per compatibilità con partite già in corso senza "movedBy".
    final attacker = board.getPiece(from);
    if (attacker == null || attacker.side == localSide) {
      _lastAppliedMoveIndex = moveIndex;
      return;
    }

    // Riallinea esplicitamente il turno al lato che ha mosso lato server.
    // Evita ritardi/desync quando i turni locali si sono sfalsati.
    currentTurn = attacker.side;
    _lastAppliedMoveIndex = moveIndex;
    _applyingRemote = true;
    executeMove(from, to);
    _applyingRemote = false;
  }

  /// Abbandona la partita in corso.
  Future<void> abandonGame() async {
    if (_isDisposed) return;
    final mySideStr = _mySide == PlayerSide.player1 ? 'player1' : 'player2';
    try {
      await FirebaseService.abandonGame(gameCode, mySideStr);
    } catch (_) {
      // Anche in caso di errore rete mostriamo l'esito locale al giocatore.
    }
    if (_isDisposed) return;
    phase = GamePhase.gameOver;
    _applyLossResult();
    _showEndDialog = true;
    _endDialogOutcome = OnlineMatchOutcome.abandoned;
    _safeNotifyListeners();
  }

  void _applyWinResult() {
    if (_resultApplied || _isDisposed) return;
    myProfile.registerWin(coinsReward: 200);
    _resultApplied = true;
  }

  void _applyLossResult() {
    if (_resultApplied || _isDisposed) return;
    myProfile.registerLoss(coinsReward: 10);
    _resultApplied = true;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _gameSubscription?.cancel();
    super.dispose();
  }
}
