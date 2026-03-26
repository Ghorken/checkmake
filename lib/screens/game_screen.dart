// lib/screens/game_screen.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/providers/online_game_provider.dart';
import 'package:checkmake/widgets/game_board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showingEndDialog = false;
  int? _coinsAtMatchStart;
  bool _startedLocalCoinFlip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybeStartLocalCoinFlip());
    });
  }

  Future<void> _maybeStartLocalCoinFlip() async {
    if (_startedLocalCoinFlip || !mounted) return;
    final game = context.read<GameProvider>();
    if (!game.hotseatMode) return;

    _startedLocalCoinFlip = true;
    final startingSide = await showDialog<PlayerSide>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LocalCoinFlipDialog(),
    );
    if (!mounted) return;
    game.startHotseatMatch(startingSide ?? PlayerSide.player1);
  }

  Future<void> _navigateHome() async {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _handleBackRequested() async {
    await _handleSurrenderRequested(PlayerSide.player1, upsideDown: false);
  }

  Future<void> _handleSurrenderRequested(
    PlayerSide side, {
    required bool upsideDown,
  }) async {
    final game = context.read<GameProvider>();
    final l = AppLocalizations.of(context)!;
    final shouldSurrender = await showDialog<bool>(
          context: context,
          builder: (ctx) => Transform.rotate(
            angle: upsideDown ? math.pi : 0,
            child: AlertDialog(
              backgroundColor: const Color(0xFF16213E),
              title: Text(
                l.gameLeaveConfirmTitle,
                style: const TextStyle(color: Colors.amber),
              ),
              content: Text(
                game.hotseatMode
                    ? 'Giocatore ${side == PlayerSide.player1 ? 1 : 2}, vuoi ritirarti dalla partita?'
                    : l.gameLeaveConfirmBody,
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
          ),
        ) ??
        false;

    if (!shouldSurrender || !mounted) return;

    if (game is OnlineGameProvider && game.phase != GamePhase.gameOver) {
      await game.abandonGame();
      return;
    }

    await _navigateHome();
  }

  void _maybeShowEndDialog(GameProvider game) {
    if (_showingEndDialog) return;

    if (game is OnlineGameProvider) {
      if (!game.showEndDialog) return;
      final outcome = game.endDialogOutcome;
      if (outcome == null) return;

      _showingEndDialog = true;
      game.consumeEndDialog();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final l = AppLocalizations.of(context)!;
        final gainedRaw =
            game.myProfile.coins - (_coinsAtMatchStart ?? game.myProfile.coins);
        final gained = gainedRaw < 0 ? 0 : gainedRaw;
        final (title, body) = switch (outcome) {
          OnlineMatchOutcome.victory => (
              l.gameResultVictoryTitle,
              l.gameResultVictoryBody
            ),
          OnlineMatchOutcome.defeat => (
              l.gameResultDefeatTitle,
              l.gameResultDefeatBody
            ),
          OnlineMatchOutcome.abandoned => (
              l.gameResultAbandonedTitle,
              l.gameResultAbandonedBody
            ),
        };

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF16213E),
            title: Text(
              title,
              style: const TextStyle(color: Colors.amber),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  l.gameResultCoins(gained),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        _showingEndDialog = false;
        await _navigateHome();
      });
      return;
    }

    if (!game.hotseatMode || game.phase != GamePhase.gameOver) return;

    _showingEndDialog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final p1HasKing = game.board.findKing(PlayerSide.player1) != null;
      final p2HasKing = game.board.findKing(PlayerSide.player2) != null;

      _LocalMatchOutcome p1Outcome;
      _LocalMatchOutcome p2Outcome;
      if (p1HasKing && !p2HasKing) {
        p1Outcome = _LocalMatchOutcome.victory;
        p2Outcome = _LocalMatchOutcome.defeat;
      } else if (!p1HasKing && p2HasKing) {
        p1Outcome = _LocalMatchOutcome.defeat;
        p2Outcome = _LocalMatchOutcome.victory;
      } else {
        p1Outcome = _LocalMatchOutcome.draw;
        p2Outcome = _LocalMatchOutcome.draw;
      }

      bool closing = false;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: const Color(0xFF16213E),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: math.pi,
                  child: _LocalEndSection(
                    title: _titleForLocalOutcome(p2Outcome),
                    body: _bodyForLocalOutcome(p2Outcome),
                    buttonLabel: 'Torna alla home',
                    isClosing: closing,
                    onClose: () async {
                      if (closing) return;
                      setState(() => closing = true);
                      Navigator.pop(ctx);
                      await _navigateHome();
                    },
                  ),
                ),
                const Divider(color: Color(0xFFD4AF37), height: 20),
                _LocalEndSection(
                  title: _titleForLocalOutcome(p1Outcome),
                  body: _bodyForLocalOutcome(p1Outcome),
                  buttonLabel: 'Torna alla home',
                  isClosing: closing,
                  onClose: () async {
                    if (closing) return;
                    setState(() => closing = true);
                    Navigator.pop(ctx);
                    await _navigateHome();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _titleForLocalOutcome(_LocalMatchOutcome outcome) => switch (outcome) {
        _LocalMatchOutcome.victory => 'Vittoria!',
        _LocalMatchOutcome.defeat => 'Sconfitta',
        _LocalMatchOutcome.draw => 'Pareggio',
      };

  String _bodyForLocalOutcome(_LocalMatchOutcome outcome) => switch (outcome) {
        _LocalMatchOutcome.victory => 'Hai vinto la partita.',
        _LocalMatchOutcome.defeat => 'Hai perso la partita.',
        _LocalMatchOutcome.draw => 'La partita è terminata in pareggio.',
      };

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    _coinsAtMatchStart ??= game.myProfile.coins;
    _maybeShowEndDialog(game);
    final showTopTurnBanner = game.hotseatMode &&
        game.phase != GamePhase.gameOver &&
        game.currentTurn == PlayerSide.player2;
    final showBottomTurnBanner = game.phase == GamePhase.myTurn &&
        (!game.hotseatMode || game.currentTurn == PlayerSide.player1);

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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _OpponentBar(
                    game: game,
                    onSurrenderPressed: _handleSurrenderRequested,
                  ),
                  if (showTopTurnBanner)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: -34,
                      child: _TurnBanner(game: game, upsideDown: true),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (game.lastCombatLog != null && game.hotseatMode) ...[
                        _CombatLogBanner(
                          message: game.lastCombatLog!,
                          upsideDown: true,
                        ),
                        const SizedBox(height: 8),
                      ],
                      const GameBoardWidget(),
                      if (game.hotseatMode) ...[
                        const SizedBox(height: 8),
                        if (game.lastCombatLog != null)
                          _CombatLogBanner(
                            message: game.lastCombatLog!,
                            upsideDown: false,
                          ),
                      ] else ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 34,
                          child: game.lastCombatLog != null
                              ? _CombatLogBanner(
                                  message: game.lastCombatLog!,
                                  upsideDown: false,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _PlayerBar(
                    game: game,
                    onSurrenderPressed: _handleSurrenderRequested,
                  ),
                  if (showBottomTurnBanner)
                    Positioned(
                      left: 12,
                      right: 12,
                      top: -34,
                      child: _TurnBanner(game: game),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LocalMatchOutcome { victory, defeat, draw }

class _LocalEndSection extends StatelessWidget {
  final String title;
  final String body;
  final String buttonLabel;
  final bool isClosing;
  final Future<void> Function() onClose;

  const _LocalEndSection({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.isClosing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isClosing ? null : () => unawaited(onClose()),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: Text(
            buttonLabel,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _CombatLogBanner extends StatelessWidget {
  final String message;
  final bool upsideDown;
  const _CombatLogBanner({required this.message, required this.upsideDown});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: upsideDown ? math.pi : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF111626),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFFF8F7F2), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _LocalCoinFlipDialog extends StatefulWidget {
  const _LocalCoinFlipDialog();

  @override
  State<_LocalCoinFlipDialog> createState() => _LocalCoinFlipDialogState();
}

class _LocalCoinFlipDialogState extends State<_LocalCoinFlipDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;
  late final PlayerSide _winner;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _winner = math.Random.secure().nextBool()
        ? PlayerSide.player1
        : PlayerSide.player2;
    final targetExtra = _winner == PlayerSide.player1 ? 0.0 : math.pi;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _angle = Tween<double>(
      begin: 0,
      end: (2 * math.pi * 8) + targetExtra,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _finished = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111626),
      title: const Text(
        'Lancio della moneta',
        style: TextStyle(color: Color(0xFFD4AF37)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _angle,
            builder: (_, __) {
              final angle = _angle.value;
              final frontVisible = math.cos(angle) >= 0;
              final label = frontVisible ? '1' : '2';
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4AF37),
                    border:
                        Border.all(color: const Color(0xFFF8F7F2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        frontVisible ? 1 : -1,
                        1,
                        1,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          if (!_finished)
            const Text(
              'Lancio in corso...',
              style: TextStyle(color: Color(0xFFF8F7F2)),
              textAlign: TextAlign.center,
            ),
          if (_finished)
            Text(
              _winner == PlayerSide.player1
                  ? 'Il giocatore 1 inizia la partita.'
                  : 'Il giocatore 2 inizia la partita.',
              style: const TextStyle(color: Color(0xFFF8F7F2)),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actions: [
        if (_finished)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _winner),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37)),
            child: const Text(
              'Inizia partita',
              style: TextStyle(color: Colors.black),
            ),
          ),
      ],
    );
  }
}

class _OpponentBar extends StatelessWidget {
  final GameProvider game;
  final Future<void> Function(
    PlayerSide side, {
    required bool upsideDown,
  }) onSurrenderPressed;
  const _OpponentBar({
    required this.game,
    required this.onSurrenderPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final modeLabel =
        game is OnlineGameProvider ? l.gameModeOnline : l.gameModeLocal;

    return Transform.rotate(
      angle: game.hotseatMode ? math.pi : 0,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: const Color(0xFF111626),
        child: Row(
          children: [
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
                  game.hotseatMode ? 'Giocatore 2' : game.opponentProfile.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (game.hotseatMode)
              IconButton(
                onPressed: () => unawaited(
                  onSurrenderPressed(
                    PlayerSide.player2,
                    upsideDown: true,
                  ),
                ),
                icon: const Icon(Icons.flag, color: Colors.redAccent),
                tooltip: l.gameLeaveConfirmTitle,
              ),
            if (!game.hotseatMode && game.phase == GamePhase.opponentTurn)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1E2D).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Text(
                  '${l.gameOpponentTurn} · ${game.turnSecondsLeft}s',
                  style:
                      const TextStyle(color: Color(0xFFF8F7F2), fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  final GameProvider game;
  final Future<void> Function(
    PlayerSide side, {
    required bool upsideDown,
  }) onSurrenderPressed;
  const _PlayerBar({
    required this.game,
    required this.onSurrenderPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final modeLabel =
        game is OnlineGameProvider ? l.gameModeOnline : l.gameModeLocal;

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
                    game.hotseatMode ? 'Giocatore 1' : game.myProfile.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      modeLabel,
                      style: const TextStyle(
                        color: Color(0xFFF8F7F2),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!game.hotseatMode)
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
              IconButton(
                onPressed: () => unawaited(
                  onSurrenderPressed(
                    PlayerSide.player1,
                    upsideDown: false,
                  ),
                ),
                icon: const Icon(Icons.flag, color: Colors.redAccent),
                tooltip: l.gameLeaveConfirmTitle,
              ),
              if (game.phase == GamePhase.myTurn) ...[
                if (game.selectedPosition != null) ...[
                  _AbilityButton(game: game),
                  const SizedBox(width: 8),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  final GameProvider game;
  final bool upsideDown;
  const _TurnBanner({required this.game, this.upsideDown = false});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final message = game.turnAction == TurnAction.moved
        ? l.gameTurnMoved
        : game.turnAction == TurnAction.usedAbility
            ? l.gameTurnAbility
            : null;

    return Transform.rotate(
      angle: upsideDown ? math.pi : 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border:
              Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.8)),
        ),
        child: Text(
          message != null
              ? '$message (${game.turnSecondsLeft}s)'
              : '${l.gameTurnSelect} (${game.turnSecondsLeft}s)',
          style: const TextStyle(color: Color(0xFFF8F7F2), fontSize: 11),
          textAlign: TextAlign.center,
        ),
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
