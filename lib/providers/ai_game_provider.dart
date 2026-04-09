// lib/providers/ai_game_provider.dart
// Provider per la modalità Allenamento (giocatore vs IA)

import 'dart:async';

import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/services/ai_service.dart';

class AIGameProvider extends GameProvider {
  static const _aiThinkDelayMs = 900;

  Timer? _aiMoveTimer;
  bool _aiMovePending = false;

  AIGameProvider({
    required super.myProfile,
    required PlayerProfile aiProfile,
  }) : super(
          opponentProfile: aiProfile,
          hotseatMode: false,
          trainingMode: true,
          initialTurn: PlayerSide.player1,
          startPaused: true,
        ) {
    addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (_aiMovePending) return;
    if (phase == GamePhase.gameOver) return;
    if (currentTurn == PlayerSide.player2) {
      _aiMovePending = true;
      _aiMoveTimer = Timer(
        const Duration(milliseconds: _aiThinkDelayMs),
        _doAiMove,
      );
    }
  }

  void _doAiMove() {
    _aiMovePending = false;
    if (phase == GamePhase.gameOver) return;
    if (currentTurn != PlayerSide.player2) return;

    final move = AIService.getBestMove(board, PlayerSide.player2);
    if (move != null) {
      executeMove(move.from, move.to);
    } else {
      endTurn();
    }
  }

  @override
  void dispose() {
    _aiMoveTimer?.cancel();
    super.dispose();
  }
}
