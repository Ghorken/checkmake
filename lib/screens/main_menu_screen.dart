// lib/screens/main_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/providers/shop_provider.dart';
import 'package:checkmake/screens/game_screen.dart';
import 'package:checkmake/screens/shop_screen.dart';
import 'package:checkmake/screens/army_builder_screen.dart';
import 'package:checkmake/screens/matchmaking_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerProfile>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0B0B10),
                    const Color(0xFF12244D).withValues(alpha: 0.95),
                    const Color(0xFF8B1E2D).withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  l.appTitle,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(color: Color(0xFF8B1E2D), blurRadius: 16),
                    ],
                  ),
                ),
                Text(
                  l.appSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFF8F7F2),
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats giocatore
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat('🪙', '${profile.coins}', l.statCoins),
                      _Stat('🏆', '${profile.wins}', l.statWins),
                      _Stat('💀', '${profile.losses}', l.statLosses),
                    ],
                  ),
                ),

                const Spacer(),

                _MenuButton(
                  icon: Icons.sports_esports,
                  label: l.btnPlay,
                  color: const Color(0xFFD4AF37),
                  onTap: () => _startGame(context, profile),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.wifi,
                  label: l.btnMultiplayer,
                  color: const Color(0xFF8B1E2D),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChangeNotifierProvider<PlayerProfile>.value(
                        value: profile,
                        child: const MatchmakingScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.shield,
                  label: l.btnBuildArmy,
                  color: const Color(0xFF1E3A8A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChangeNotifierProvider<PlayerProfile>.value(
                        value: profile,
                        child: const ArmyBuilderScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  icon: Icons.store,
                  label: l.btnShop,
                  color: const Color(0xFFF8F7F2),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ShopProvider(profile: profile),
                        child: const ShopScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context, PlayerProfile myProfile) {
    final opponent = PlayerProfile.fromJson({
      ...myProfile.toJson(),
      'name': 'Giocatore 2',
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GameProvider(
            myProfile: myProfile,
            opponentProfile: opponent,
            hotseatMode: true,
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: color),
          label: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B0B10).withValues(alpha: 0.74),
            side: BorderSide(color: color, width: 1.8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _Stat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text('$emoji $value',
              style: const TextStyle(
                  color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Color(0xFFF8F7F2), fontSize: 10)),
        ],
      );
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 60.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
