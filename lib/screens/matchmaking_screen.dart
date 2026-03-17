// lib/screens/matchmaking_screen.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crownfall/models/piece.dart';
import 'package:crownfall/models/player_profile.dart';
import 'package:crownfall/providers/online_game_provider.dart';
import 'package:crownfall/screens/game_screen.dart';
import 'package:crownfall/services/firebase_service.dart';

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
    if (code.length != 6) {
      setState(() => _errorMessage = 'Il codice deve essere di 6 caratteri.');
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

      // Recupera i dati di player1 e avvia la partita come player2
      final doc = await FirebaseService.watchGame(code).first;
      final data = doc.data() as Map<String, dynamic>;
      final opponentProfile = FirebaseService.profileFromData(
        data['player1'] as Map<String, dynamic>,
      );

      if (mounted) {
        _navigateToGame(
          myProfile: profile,
          opponentProfile: opponentProfile,
          mySide: PlayerSide.player2,
          gameCode: code,
        );
      }
    } catch (e) {
      setState(() {
        _uiState = _UIState.idle;
        _errorMessage = 'Errore durante la connessione: $e';
      });
    }
  }

  // ── Attende che player2 si unisca (dopo aver creato la partita) ───────────

  void _waitForOpponent(String code, PlayerSide mySide, PlayerProfile profile) {
    _waitingSubscription = FirebaseService.watchGame(code).listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      if (data['status'] == 'playing' && data['player2'] != null) {
        _waitingSubscription?.cancel();

        final opponentProfile = FirebaseService.profileFromData(
          data['player2'] as Map<String, dynamic>,
        );

        if (mounted) {
          _navigateToGame(
            myProfile: profile,
            opponentProfile: opponentProfile,
            mySide: mySide,
            gameCode: code,
          );
        }
      }
    });
  }

  // ── Naviga alla schermata di gioco ────────────────────────────────────────

  void _navigateToGame({
    required PlayerProfile myProfile,
    required PlayerProfile opponentProfile,
    required PlayerSide mySide,
    required String gameCode,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => OnlineGameProvider(
            myProfile: myProfile,
            opponentProfile: opponentProfile,
            mySide: mySide,
            gameCode: gameCode,
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }

  // ── Annulla la partita in attesa ──────────────────────────────────────────

  void _cancelWaiting() {
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
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        title: const Text(
          'SFIDA ONLINE',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _buildBody(),
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
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text('Connessione in corso…', style: TextStyle(color: Colors.white70)),
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

// ─── Stato UI ────────────────────────────────────────────────────────────────

enum _UIState { idle, creating, joining, waitingForOpponent }

// ─── Vista Idle: crea o unisciti ─────────────────────────────────────────────

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),

        // Sezione "Crea partita"
        _SectionCard(
          color: Colors.amber,
          icon: Icons.add_circle_outline,
          title: 'Crea Partita',
          subtitle: 'Genera un codice e condividilo con l\'amico',
          child: ElevatedButton.icon(
            onPressed: onCreateGame,
            icon: const Icon(Icons.play_arrow),
            label: const Text('CREA PARTITA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Row(children: [
          Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('oppure', style: TextStyle(color: Colors.white38)),
          ),
          Expanded(child: Divider(color: Colors.white24)),
        ]),
        const SizedBox(height: 20),

        // Sezione "Unisciti"
        _SectionCard(
          color: Colors.cyan,
          icon: Icons.link,
          title: 'Unisciti a una Partita',
          subtitle: 'Inserisci il codice ricevuto dall\'avversario',
          child: Column(
            children: [
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'CODICE',
                  hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 4),
                  filled: true,
                  fillColor: const Color(0xFF0F3460),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyan),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyan, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onJoinGame,
                icon: const Icon(Icons.login),
                label: const Text('UNISCITI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Vista attesa avversario ──────────────────────────────────────────────────

class _WaitingForOpponentView extends StatelessWidget {
  final String gameCode;
  final VoidCallback onCancel;

  const _WaitingForOpponentView({required this.gameCode, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_tethering, color: Colors.amber, size: 64),
          const SizedBox(height: 24),
          const Text(
            'In attesa dell\'avversario…',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Condividi questo codice con il tuo amico:',
            style: TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Codice partita con pulsante copia
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gameCode,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.amber),
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
            child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 3),
          ),
          const SizedBox(height: 32),

          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text('Annulla', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Card sezione ─────────────────────────────────────────────────────────────

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
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
