// lib/screens/game_screen.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/providers/online_game_provider.dart';
import 'package:checkmake/widgets/game_board_widget.dart';

// Medieval palette
const _gold = Color(0xFFD4AF37);
const _crimson = Color(0xFF8B1E2D);
const _bloodRed = Color(0xFF6B0F1A);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);
const _steelBlue = Color(0xFF2B5798);

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
    if (!game.hotseatMode && !game.trainingMode) return;

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
    if (_showingEndDialog) {
      Navigator.popUntil(context, (route) => route.isFirst);
      await _navigateHome();
      return;
    }
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
              backgroundColor: _darkStone,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: _gold.withValues(alpha: 0.4)),
              ),
              title: Text(
                l.gameLeaveConfirmTitle,
                style: GoogleFonts.cinzelDecorative(
                  color: _gold,
                  fontSize: 18,
                ),
              ),
              content: Text(
                game.hotseatMode
                    ? 'Giocatore ${side == PlayerSide.player1 ? 1 : 2}, vuoi ritirarti dalla partita?'
                    : l.gameLeaveConfirmBody,
                style: GoogleFonts.lora(
                  color: _parchment.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.gameLeaveConfirmCancel,
                      style: const TextStyle(color: _parchment)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bloodRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: Text(l.gameLeaveConfirmOk,
                      style: const TextStyle(color: _parchment)),
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
            backgroundColor: _darkStone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: _gold.withValues(alpha: 0.4)),
            ),
            title: Text(
              title,
              style: GoogleFonts.cinzelDecorative(
                color: _gold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: GoogleFonts.lora(
                    color: _parchment.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.gameResultCoins(gained),
                  style: GoogleFonts.cinzel(
                    color: _gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: Text(
                  l.gameDialogClose,
                  style: const TextStyle(color: _ironBlack),
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

    if (game.trainingMode && game.phase == GamePhase.gameOver) {
      _showingEndDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final l = AppLocalizations.of(context)!;
        final myKingAlive =
            game.board.findKing(PlayerSide.player1) != null;
        final title = myKingAlive
            ? l.gameResultVictoryTitle
            : l.gameResultDefeatTitle;
        final body = myKingAlive
            ? l.gameResultTrainingVictoryBody
            : l.gameResultTrainingDefeatBody;
        final gainedRaw =
            game.myProfile.coins - (_coinsAtMatchStart ?? game.myProfile.coins);
        final gained = gainedRaw < 0 ? 0 : gainedRaw;

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: _darkStone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: _gold.withValues(alpha: 0.4)),
            ),
            title: Text(
              title,
              style: GoogleFonts.cinzelDecorative(
                color: _gold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: GoogleFonts.lora(
                    color: _parchment.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.gameResultCoins(gained),
                  style: GoogleFonts.cinzel(
                    color: _gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: Text(
                  l.gameDialogClose,
                  style: const TextStyle(color: _ironBlack),
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
            backgroundColor: _darkStone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: _gold.withValues(alpha: 0.4)),
            ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: _gold.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.shield,
                            color: _gold.withValues(alpha: 0.4), size: 16),
                      ),
                      Expanded(
                          child: Divider(
                              color: _gold.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
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
        backgroundColor: _ironBlack,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _darkStone.withValues(alpha: 0.6),
                _ironBlack,
                _darkStone.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: SafeArea(
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
                        if (game.hotseatMode) ...[
                          SizedBox(
                            height: 34,
                            child: game.lastCombatLog != null
                                ? _CombatLogBanner(
                                    message: game.lastCombatLog!,
                                    upsideDown: true,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const GameBoardWidget(),
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
                    ),
                  ),
                ),
                // Sezione abilità (tra il log dello scontro e il banner del turno)
                _AbilityInfoSection(game: game),
                // Banner del turno (spazio fisso 34px)
                SizedBox(
                  height: 34,
                  child: showBottomTurnBanner
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: _TurnBanner(game: game),
                        )
                      : null,
                ),
                _PlayerBar(
                  game: game,
                  onSurrenderPressed: _handleSurrenderRequested,
                ),
              ],
            ),
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
          style: GoogleFonts.cinzelDecorative(
            color: _gold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: GoogleFonts.lora(
            color: _parchment.withValues(alpha: 0.9),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isClosing ? null : () => unawaited(onClose()),
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          child: Text(
            buttonLabel,
            style: const TextStyle(color: _ironBlack),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMBAT LOG BANNER (scroll/parchment style)
// ═══════════════════════════════════════════════════════════════════════════════
class _CombatLogBanner extends StatelessWidget {
  final String message;
  final bool upsideDown;
  const _CombatLogBanner({required this.message, required this.upsideDown});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: upsideDown ? math.pi : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1208).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: _crimson.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _crimson.withValues(alpha: 0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department,
                color: _crimson.withValues(alpha: 0.7), size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.cinzel(
                  color: _parchment,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.local_fire_department,
                color: _crimson.withValues(alpha: 0.7), size: 14),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COIN FLIP DIALOG (medieval)
// ═══════════════════════════════════════════════════════════════════════════════
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
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
      backgroundColor: _darkStone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: _gold.withValues(alpha: 0.4)),
      ),
      title: Text(
        'Lancio della moneta',
        style: GoogleFonts.cinzelDecorative(color: _gold, fontSize: 18),
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFF0D060), _gold, Color(0xFF9A7B2A)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(color: const Color(0xFF9A7B2A), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.5),
                        blurRadius: 16,
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
                        style: GoogleFonts.cinzelDecorative(
                          color: _ironBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (!_finished)
            Text(
              'Lancio in corso...',
              style: GoogleFonts.cinzel(color: _parchment, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          if (_finished)
            Text(
              _winner == PlayerSide.player1
                  ? 'Il giocatore 1 inizia la partita.'
                  : 'Il giocatore 2 inizia la partita.',
              style: GoogleFonts.cinzel(color: _parchment, fontSize: 13),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actions: [
        if (_finished)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _winner),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: Text(
              'Inizia partita',
              style: GoogleFonts.cinzel(
                color: _ironBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OPPONENT BAR (top - enemy banner)
// ═══════════════════════════════════════════════════════════════════════════════
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1225),
              _darkStone.withValues(alpha: 0.95),
              _crimson.withValues(alpha: 0.25),
            ],
          ),
          border: game.hotseatMode
              ? Border(
                  top: BorderSide(
                    color: _crimson.withValues(alpha: 0.55),
                    width: 2,
                  ),
                )
              : Border(
                  bottom: BorderSide(
                    color: _crimson.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
          boxShadow: [
            BoxShadow(
              color: _crimson.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Player 2 shield avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _crimson.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: _crimson, width: 1.5),
              ),
              child: const Icon(Icons.shield, color: _crimson, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.hotseatMode ? 'Giocatore 2' : game.opponentProfile.name,
                  style: GoogleFonts.cinzel(
                    color: _parchment,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _crimson.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                        color: _crimson.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    modeLabel,
                    style: GoogleFonts.cinzel(
                      color: _parchment.withValues(alpha: 0.7),
                      fontSize: 9,
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
                icon: const Icon(Icons.flag, color: _crimson),
                tooltip: l.gameLeaveConfirmTitle,
              ),
            if (!game.hotseatMode && game.phase == GamePhase.opponentTurn)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _crimson.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: _crimson.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${l.gameOpponentTurn} · ${game.turnSecondsLeft}s',
                  style: GoogleFonts.cinzel(
                    color: _parchment,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PLAYER BAR (bottom - allied banner)
// ═══════════════════════════════════════════════════════════════════════════════
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D1225),
            _darkStone.withValues(alpha: 0.95),
            _steelBlue.withValues(alpha: 0.2),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: _steelBlue.withValues(alpha: 0.55),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _steelBlue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Player 1 shield avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _steelBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: _steelBlue, width: 1.5),
                ),
                child:
                    const Icon(Icons.shield, color: _steelBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.hotseatMode ? 'Giocatore 1' : game.myProfile.name,
                    style: GoogleFonts.cinzel(
                      color: _parchment,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _steelBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: _steelBlue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      modeLabel,
                      style: GoogleFonts.cinzel(
                        color: _parchment.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!game.hotseatMode)
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: _gold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${game.myProfile.coins}',
                          style: GoogleFonts.cinzel(
                            color: _gold,
                            fontSize: 12,
                          ),
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
                icon: const Icon(Icons.flag, color: _crimson),
                tooltip: l.gameLeaveConfirmTitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TURN BANNER (war horn / battle cry style)
// ═══════════════════════════════════════════════════════════════════════════════
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
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _darkStone.withValues(alpha: 0.95),
              const Color(0xFF1A1208).withValues(alpha: 0.95),
              _darkStone.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: _gold.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          message != null
              ? '$message (${game.turnSecondsLeft}s)'
              : '${l.gameTurnSelect} (${game.turnSecondsLeft}s)',
          style: GoogleFonts.cinzel(
            color: _gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ABILITY INFO SECTION
// Spazio fisso tra il log dello scontro e il banner del turno.
// Passiva: mostra icona + nome + descrizione.
// Attiva: mostra icona + nome + descrizione + pulsante di attivazione.
// ═══════════════════════════════════════════════════════════════════════════════
class _AbilityInfoSection extends StatelessWidget {
  final GameProvider game;
  const _AbilityInfoSection({required this.game});

  @override
  Widget build(BuildContext context) {
    final pos = game.selectedPosition;
    final piece = pos != null ? game.board.getPiece(pos) : null;
    final ability =
        (piece != null && piece.side == game.interactiveSide)
            ? piece.specialAbility
            : null;

    // Spazio fisso: 48px — vuoto se nessuna abilità da mostrare
    if (ability == null) return const SizedBox(height: 48);

    final l = AppLocalizations.of(context)!;
    final abilityName = l.abilityNameFor(ability.id);
    final abilityDesc = l.abilityDescFor(ability.id);
    final isPassive = ability.isPassive;
    final accent = isPassive ? _steelBlue : _crimson;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                isPassive ? Icons.shield : Icons.local_fire_department,
                color: accent,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$abilityName  ',
                        style: GoogleFonts.cinzel(
                          color: _parchment,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: abilityDesc,
                        style: GoogleFonts.lora(
                          color: _parchment.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isPassive) ...[
                const SizedBox(width: 8),
                _ActiveAbilityButton(game: game, pos: pos!, ability: ability),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveAbilityButton extends StatelessWidget {
  final GameProvider game;
  final Position pos;
  final SpecialAbility ability;

  const _ActiveAbilityButton({
    required this.game,
    required this.pos,
    required this.ability,
  });

  @override
  Widget build(BuildContext context) {
    final canUse = ability.isReady && game.canUseAbility;
    final label = ability.currentCooldown > 0
        ? 'CD ${ability.currentCooldown}'
        : 'Usa';

    return ElevatedButton(
      onPressed: canUse ? () => game.useAbility(pos) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canUse ? _crimson : Colors.grey.shade800,
        foregroundColor: _parchment,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(0, 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(
            color: canUse ? _gold.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cinzel(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _parchment,
        ),
      ),
    );
  }
}
