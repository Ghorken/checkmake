// lib/screens/game_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/providers/online_game_provider.dart';
import 'package:checkmake/widgets/game_board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showingVictoryDialog = false;

  Future<void> _navigateHome() async {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleBackRequested() async {
    final game = context.read<GameProvider>();
    final l = AppLocalizations.of(context)!;

    final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF16213E),
            title: Text(
              l.gameLeaveConfirmTitle,
              style: const TextStyle(color: Colors.amber),
            ),
            content: Text(
              l.gameLeaveConfirmBody,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.gameLeaveConfirmCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(l.gameLeaveConfirmOk),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLeave) return;

    if (game is OnlineGameProvider && game.phase != GamePhase.gameOver) {
      unawaited(
        game.abandonGame().catchError((_) {
          // Navigazione prioritaria: ignoriamo eventuali errori di rete qui.
        }),
      );
    }

    await _navigateHome();
  }

  void _maybeShowVictoryDialog(GameProvider game) {
    if (_showingVictoryDialog ||
        game is! OnlineGameProvider ||
        !game.showVictoryDialog) {
      return;
    }

    _showingVictoryDialog = true;
    game.consumeVictoryDialog();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            l.gameWinByForfeitTitle,
            style: const TextStyle(color: Colors.amber),
          ),
          content: Text(
            l.gameWinByForfeitBody,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: Text(
                l.gameDialogClose,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
      _showingVictoryDialog = false;
      await _navigateHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    _maybeShowVictoryDialog(game);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_handleBackRequested());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0B10),
        body: SafeArea(
          child: Column(
            children: [
              _OpponentBar(
                game: game,
                onBackPressed: _handleBackRequested,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GameBoardWidget(),
                      const SizedBox(height: 8),
                      if (game.lastCombatLog != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111626),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            game.lastCombatLog!,
                            style: const TextStyle(
                                color: Color(0xFFF8F7F2), fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _PlayerBar(game: game),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpponentBar extends StatelessWidget {
  final GameProvider game;
  final Future<void> Function() onBackPressed;
  const _OpponentBar({required this.game, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final modeLabel =
        game is OnlineGameProvider ? l.gameModeOnline : l.gameModeLocal;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFF111626),
      child: Row(
        children: [
          IconButton(
            onPressed: () => unawaited(onBackPressed()),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFF8B1E2D),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.opponentProfile.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
            ),
            child: Text(
              modeLabel,
              style: const TextStyle(
                color: Color(0xFFF8F7F2),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          if (game.phase == GamePhase.opponentTurn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B1E2D).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Text(
                '${l.gameOpponentTurn} · ${game.turnSecondsLeft}s',
                style: const TextStyle(color: Color(0xFFF8F7F2), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  final GameProvider game;
  const _PlayerBar({required this.game});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isMyTurn = game.phase == GamePhase.myTurn;

    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF111626),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.myProfile.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Color(0xFFD4AF37), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.myProfile.coins}',
                        style: const TextStyle(
                            color: Color(0xFFD4AF37), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (isMyTurn) ...[
                if (game.selectedPosition != null) ...[
                  _AbilityButton(game: game),
                  const SizedBox(width: 8),
                ],
              ],
            ],
          ),
          if (isMyTurn)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.8)),
                ),
                child: Text(
                  '${game.turnAction == TurnAction.moved ? l.gameTurnMoved : game.turnAction == TurnAction.usedAbility ? l.gameTurnAbility : l.gameTurnSelect} (${game.turnSecondsLeft}s)',
                  style:
                      const TextStyle(color: Color(0xFFF8F7F2), fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AbilityButton extends StatelessWidget {
  final GameProvider game;
  const _AbilityButton({required this.game});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pos = game.selectedPosition!;
    final piece = game.board.getPiece(pos);
    if (piece?.specialAbility == null) return const SizedBox.shrink();

    final ability = piece!.specialAbility!;
    final canUse = ability.isReady && game.canUseAbility;
    final abilityName = l.abilityNameFor(ability.id);

    return Tooltip(
      message:
          '${l.abilityNameFor(ability.id)}: ${l.abilityDescFor(ability.id)}',
      child: ElevatedButton.icon(
        onPressed: canUse ? () => game.useAbility(pos) : null,
        icon: const Icon(Icons.flash_on, size: 14),
        label: Text(abilityName, style: const TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          backgroundColor: canUse ? const Color(0xFF8B1E2D) : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
      ),
    );
  }
}
