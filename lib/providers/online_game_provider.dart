// lib/providers/online_game_provider.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/services/firebase_service.dart';

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

  OnlineGameProvider({
    required super.myProfile,
    required super.opponentProfile,
    required PlayerSide mySide,
    required this.gameCode,
  })  : _mySide = mySide {
    // Player1 inizia sempre; se siamo player2 aspettiamo la mossa avversaria
    if (_mySide == PlayerSide.player2) {
      currentTurn = PlayerSide.player1; // il turno appartiene a player1
    }
    _listenToGame();
  }

  @override
  PlayerSide get localSide => _mySide;

  // ── Override executeMove: invia la mossa a Firebase se è locale ───────────

  @override
  void executeMove(Position from, Position to) {
    super.executeMove(from, to);

    // Invia a Firebase solo se non stiamo applicando una mossa remota
    if (!_applyingRemote) {
      FirebaseService.sendMove(gameCode, from.row, from.col, to.row, to.col);

      // Se la partita è finita, notifica il server
      if (phase == GamePhase.gameOver) {
        final winner = currentTurn == PlayerSide.player1 ? 'player2' : 'player1';
        FirebaseService.setWinner(gameCode, winner);
      }
    }
  }

  // ── Listener Firestore ────────────────────────────────────────────────────

  void _listenToGame() {
    _gameSubscription = FirebaseService.watchGame(gameCode).listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;

      _handleGameUpdate(data);
    });
  }

  void _handleGameUpdate(Map<String, dynamic> data) {
    // Partita terminata da remoto (es. avversario ha abbandonato)
    final serverWinner = data['winner'] as String?;
    final serverStatus = data['status'] as String?;
    if (serverStatus == 'finished' && serverWinner != null && phase != GamePhase.gameOver) {
      phase = GamePhase.gameOver;
      final mySideStr = _mySide == PlayerSide.player1 ? 'player1' : 'player2';
      if (serverWinner == mySideStr) {
        myProfile.wins++;
        myProfile.coins += 200;
      } else {
        myProfile.losses++;
        myProfile.coins += 10;
      }
      notifyListeners();
      return;
    }

    // Nuova mossa dell'avversario
    final lastMoveData = data['lastMove'] as Map<String, dynamic>?;
    if (lastMoveData == null) return;

    final moveIndex = lastMoveData['moveIndex'] as int;

    // Applica la mossa solo se:
    // 1. È più recente dell'ultima che abbiamo applicato
    // 2. Il turno corrente NON è il nostro (è la mossa dell'avversario)
    if (moveIndex > _lastAppliedMoveIndex && !isLocalTurn) {
      _lastAppliedMoveIndex = moveIndex;

      final from = Position(
        lastMoveData['fromRow'] as int,
        lastMoveData['fromCol'] as int,
      );
      final to = Position(
        lastMoveData['toRow'] as int,
        lastMoveData['toCol'] as int,
      );

      _applyingRemote = true;
      executeMove(from, to);
      _applyingRemote = false;
    }
  }

  /// Abbandona la partita in corso.
  Future<void> abandonGame() async {
    final mySideStr = _mySide == PlayerSide.player1 ? 'player1' : 'player2';
    await FirebaseService.abandonGame(gameCode, mySideStr);
    phase = GamePhase.gameOver;
    myProfile.losses++;
    myProfile.coins += 10;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }
}
