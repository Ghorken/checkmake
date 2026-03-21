// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/widgets/game_board_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _OpponentBar(game: game),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game.lastCombatLog!,
                          style: const TextStyle(color: Colors.amber, fontSize: 12),
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
    );
  }
}

class _OpponentBar extends StatelessWidget {
  final GameProvider game;
  const _OpponentBar({required this.game});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF16213E),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.opponentProfile.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                '${game.opponentProfile.wins}V - ${game.opponentProfile.losses}S',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          if (game.phase == GamePhase.opponentTurn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
              ),
              child: Text(l.gameOpponentTurn, style: const TextStyle(color: Colors.red, fontSize: 11)),
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
      color: const Color(0xFF16213E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.cyan,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.myProfile.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.myProfile.coins}',
                        style: const TextStyle(color: Colors.amber, fontSize: 12),
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
                ElevatedButton.icon(
                  onPressed: game.endTurn,
                  icon: const Icon(Icons.skip_next, size: 16),
                  label: Text(l.gameEndTurn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3460),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
              if (game.phase == GamePhase.gameOver)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text(l.gameOver, style: const TextStyle(color: Colors.black)),
                ),
            ],
          ),
          if (isMyTurn)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.cyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  game.turnAction == TurnAction.moved
                      ? l.gameTurnMoved
                      : game.turnAction == TurnAction.usedAbility
                          ? l.gameTurnAbility
                          : l.gameTurnSelect,
                  style: const TextStyle(color: Colors.cyan, fontSize: 11),
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
      message: '${l.abilityNameFor(ability.id)}: ${l.abilityDescFor(ability.id)}',
      child: ElevatedButton.icon(
        onPressed: canUse ? () => game.useAbility(pos) : null,
        icon: const Icon(Icons.flash_on, size: 14),
        label: Text(abilityName, style: const TextStyle(fontSize: 11)),
        style: ElevatedButton.styleFrom(
          backgroundColor: canUse ? Colors.purple : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
      ),
    );
  }
}
