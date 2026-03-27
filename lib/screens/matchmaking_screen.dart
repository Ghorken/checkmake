// lib/screens/matchmaking_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:checkmake/providers/game_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/providers/online_game_provider.dart';
import 'package:checkmake/screens/game_screen.dart';
import 'package:checkmake/services/firebase_service.dart';

const _gold = Color(0xFFD4AF37);
const _steelBlue = Color(0xFF2B5798);
const _crimson = Color(0xFF8B1E2D);
const _bloodRed = Color(0xFF6B0F1A);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);

/// Schermata per creare o unirsi a una partita online.
class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final _codeController = TextEditingController();

  _UIState _uiState = _UIState.idle;
  String? _createdGameCode;
  String? _errorMessage;

  StreamSubscription<DocumentSnapshot>? _waitingSubscription;

  @override
  void dispose() {
    _waitingSubscription?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  // ── Crea una nuova partita ─────────────────────────────────────────────────

  Future<void> _createGame() async {
    final profile = context.read<PlayerProfile>();
    setState(() {
      _uiState = _UIState.creating;
      _errorMessage = null;
    });

    try {
      final code = await FirebaseService.createGame(profile);
      setState(() {
        _createdGameCode = code;
        _uiState = _UIState.waitingForOpponent;
      });
      _waitForOpponent(code, PlayerSide.player1, profile);
    } catch (e) {
      setState(() {
        _uiState = _UIState.idle;
        _errorMessage = 'Errore nella creazione: $e';
      });
    }
  }

  // ── Unisciti a una partita ─────────────────────────────────────────────────

  Future<void> _joinGame() async {
    final code = _codeController.text.trim().toUpperCase();
    if (!FirebaseService.isValidGameCode(code)) {
      setState(() => _errorMessage =
          'Codice non valido. Usa 6 caratteri alfanumerici (A-Z, 0-9).');
      return;
    }

    final profile = context.read<PlayerProfile>();
    setState(() {
      _uiState = _UIState.joining;
      _errorMessage = null;
    });

    try {
      final success = await FirebaseService.joinGame(code, profile);
      if (!success) {
        setState(() {
          _uiState = _UIState.idle;
          _errorMessage = 'Codice non valido o partita già iniziata.';
        });
        return;
      }

      final doc = await FirebaseService.watchGame(code).first;
      final data = doc.data() as Map<String, dynamic>;
      final opponentProfile = FirebaseService.profileFromData(
        data['player1'] as Map<String, dynamic>,
      );

      if (mounted) {
        final startingSide =
            _parseStartingSide(data['startingSide'] as String?);
        final initiativeTie = data['initiativeTie'] == true;
        await _maybeShowCoinFlipDialog(
          initiativeTie: initiativeTie,
          startingSide: startingSide,
          mySide: PlayerSide.player2,
        );
        if (!mounted) return;
        _navigateToGame(
          myProfile: profile,
          opponentProfile: opponentProfile,
          mySide: PlayerSide.player2,
          gameCode: code,
          startingSide: startingSide,
        );
      }
    } catch (e) {
      setState(() {
        _uiState = _UIState.idle;
        _errorMessage = 'Errore durante la connessione: $e';
      });
    }
  }

  // ── Attende che player2 si unisca ─────────────────────────────────────────

  void _waitForOpponent(
      String code, PlayerSide mySide, PlayerProfile profile) {
    _waitingSubscription =
        FirebaseService.watchGame(code).listen((snap) async {
      if (!snap.exists) {
        if (!mounted) return;
        setState(() {
          _uiState = _UIState.idle;
          _createdGameCode = null;
          _errorMessage = 'Partita annullata.';
        });
        return;
      }
      final data = snap.data() as Map<String, dynamic>;
      if (data['status'] == 'playing' && data['player2'] != null) {
        _waitingSubscription?.cancel();

        final opponentProfile = FirebaseService.profileFromData(
          data['player2'] as Map<String, dynamic>,
        );

        if (mounted) {
          final startingSide =
              _parseStartingSide(data['startingSide'] as String?);
          final initiativeTie = data['initiativeTie'] == true;
          await _maybeShowCoinFlipDialog(
            initiativeTie: initiativeTie,
            startingSide: startingSide,
            mySide: mySide,
          );
          if (!mounted) return;
          _navigateToGame(
            myProfile: profile,
            opponentProfile: opponentProfile,
            mySide: mySide,
            gameCode: code,
            startingSide: startingSide,
          );
        }
      }
    });
  }

  void _navigateToGame({
    required PlayerProfile myProfile,
    required PlayerProfile opponentProfile,
    required PlayerSide mySide,
    required String gameCode,
    required PlayerSide startingSide,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<GameProvider>(
          create: (_) => OnlineGameProvider(
            myProfile: myProfile,
            opponentProfile: opponentProfile,
            mySide: mySide,
            gameCode: gameCode,
            startingSide: startingSide,
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }

  PlayerSide _parseStartingSide(String? side) {
    return side == 'player2' ? PlayerSide.player2 : PlayerSide.player1;
  }

  Future<void> _maybeShowCoinFlipDialog({
    required bool initiativeTie,
    required PlayerSide startingSide,
    required PlayerSide mySide,
  }) async {
    if (!initiativeTie || !mounted) return;
    final iStart = startingSide == mySide;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CoinFlipDialog(iStart: iStart),
    );
  }

  void _cancelWaiting() {
    unawaited(_cancelWaitingAsync());
  }

  Future<void> _cancelWaitingAsync() async {
    _waitingSubscription?.cancel();
    final code = _createdGameCode;
    if (code != null) {
      await FirebaseService.cancelWaitingGame(code);
    }

    if (!mounted) return;
    _waitingSubscription?.cancel();
    setState(() {
      _uiState = _UIState.idle;
      _createdGameCode = null;
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ironBlack,
      appBar: AppBar(
        backgroundColor: _darkStone.withValues(alpha: 0.95),
        foregroundColor: _parchment,
        title: Text(
          'SFIDA ONLINE',
          style: GoogleFonts.cinzelDecorative(
            color: _gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _darkStone.withValues(alpha: 0.4),
              _ironBlack,
              _bloodRed.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case _UIState.waitingForOpponent:
        return _WaitingForOpponentView(
          gameCode: _createdGameCode!,
          onCancel: _cancelWaiting,
        );
      case _UIState.creating:
      case _UIState.joining:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: _gold),
              const SizedBox(height: 16),
              Text('Connessione in corso...',
                  style: GoogleFonts.cinzel(color: _parchment)),
            ],
          ),
        );
      case _UIState.idle:
        return _IdleView(
          codeController: _codeController,
          errorMessage: _errorMessage,
          onCreateGame: _createGame,
          onJoinGame: _joinGame,
        );
    }
  }
}

enum _UIState { idle, creating, joining, waitingForOpponent }

// ─── Vista Idle ─────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final TextEditingController codeController;
  final String? errorMessage;
  final VoidCallback onCreateGame;
  final VoidCallback onJoinGame;

  const _IdleView({
    required this.codeController,
    required this.errorMessage,
    required this.onCreateGame,
    required this.onJoinGame,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Create game section
                _SectionCard(
                  color: _gold,
                  icon: Icons.add_circle_outline,
                  title: 'Crea Partita',
                  subtitle: 'Genera un codice e condividilo con l\'amico',
                  child: ElevatedButton.icon(
                    onPressed: onCreateGame,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('CREA PARTITA',
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: _ironBlack,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                      child: Divider(color: _gold.withValues(alpha: 0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('oppure',
                        style: GoogleFonts.cinzel(
                            color: _parchment.withValues(alpha: 0.5),
                            fontSize: 12)),
                  ),
                  Expanded(
                      child: Divider(color: _gold.withValues(alpha: 0.3))),
                ]),
                const SizedBox(height: 20),

                // Join game section
                _SectionCard(
                  color: _steelBlue,
                  icon: Icons.link,
                  title: 'Unisciti a una Partita',
                  subtitle: 'Inserisci il codice ricevuto dall\'avversario',
                  child: Column(
                    children: [
                      TextField(
                        controller: codeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                          const UpperCaseTextFormatter(),
                        ],
                        maxLength: 6,
                        style: GoogleFonts.cinzel(
                          color: _parchment,
                          fontSize: 22,
                          letterSpacing: 6,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'CODICE',
                          hintStyle: GoogleFonts.cinzel(
                              color: _parchment.withValues(alpha: 0.3),
                              letterSpacing: 4),
                          filled: true,
                          fillColor: _darkStone,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: const BorderSide(color: _gold),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(
                                color: _steelBlue.withValues(alpha: 0.5),
                                width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide:
                                const BorderSide(color: _gold, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onJoinGame,
                        icon: const Icon(Icons.login),
                        label: Text('UNISCITI',
                            style: GoogleFonts.cinzel(
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _crimson,
                          foregroundColor: _parchment,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _crimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                          color: _crimson.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: _crimson, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                                color: _parchment.withValues(alpha: 0.8),
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Waiting view ──────────────────────────────────────────────────────────

class _WaitingForOpponentView extends StatelessWidget {
  final String gameCode;
  final VoidCallback onCancel;

  const _WaitingForOpponentView(
      {required this.gameCode, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield,
              color: _gold.withValues(alpha: 0.7), size: 64),
          const SizedBox(height: 24),
          Text(
            'In attesa dell\'avversario...',
            style: GoogleFonts.cinzel(
                color: _parchment,
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Condividi questo codice con il tuo amico:',
            style: GoogleFonts.cinzel(
                color: _parchment.withValues(alpha: 0.6), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Game code display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _darkStone,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.15),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameCode,
                  style: GoogleFonts.cinzelDecorative(
                    color: _gold,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.copy, color: _gold),
                  tooltip: 'Copia codice',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: gameCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Codice copiato negli appunti!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
          ),
          const SizedBox(height: 32),

          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined, color: _crimson),
            label: Text('Annulla',
                style: GoogleFonts.cinzel(color: _crimson)),
          ),
        ],
      ),
    );
  }
}

// ─── Section card ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkStone,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  color: _parchment.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

// ─── Coin Flip Dialog ──────────────────────────────────────────────────────

class _CoinFlipDialog extends StatefulWidget {
  final bool iStart;
  const _CoinFlipDialog({required this.iStart});

  @override
  State<_CoinFlipDialog> createState() => _CoinFlipDialogState();
}

class _CoinFlipDialogState extends State<_CoinFlipDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final targetExtra = widget.iStart ? 0.0 : math.pi;
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
        'Parità iniziativa',
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
              final sideLabel = frontVisible ? 'TU' : 'AVV';
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
                      colors: [
                        Color(0xFFF0D060),
                        _gold,
                        Color(0xFF9A7B2A)
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(
                        color: const Color(0xFF9A7B2A), width: 3),
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
                        sideLabel,
                        style: GoogleFonts.cinzelDecorative(
                          color: _ironBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
              'Lancio della moneta in corso...',
              style: GoogleFonts.cinzel(color: _parchment, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          if (_finished)
            Text(
              widget.iStart
                  ? 'Hai vinto il lancio: inizi tu.'
                  : 'L\'avversario vince il lancio: inizia lui.',
              style: GoogleFonts.cinzel(color: _parchment, fontSize: 12),
              textAlign: TextAlign.center,
            ),
        ],
      ),
      actions: [
        if (_finished)
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
            ),
            child: Text(
              'Inizia partita',
              style: GoogleFonts.cinzel(
                  color: _ironBlack, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
