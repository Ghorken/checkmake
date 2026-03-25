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

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            children: [
                              _ChessMenuButton(
                                icon: Icons.sports_esports,
                                label: l.btnPlay,
                                isLightSquare: true,
                                onTap: () => _startGame(context, profile),
                              ),
                              _ChessMenuButton(
                                icon: Icons.wifi,
                                label: l.btnMultiplayer,
                                isLightSquare: false,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider<
                                        PlayerProfile>.value(
                                      value: profile,
                                      child: const MatchmakingScreen(),
                                    ),
                                  ),
                                ),
                              ),
                              _ChessMenuButton(
                                icon: Icons.shield,
                                label: l.btnBuildArmy,
                                isLightSquare: false,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider<
                                        PlayerProfile>.value(
                                      value: profile,
                                      child: const ArmyBuilderScreen(),
                                    ),
                                  ),
                                ),
                              ),
                              _ChessMenuButton(
                                icon: Icons.store,
                                label: l.btnShop,
                                isLightSquare: true,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (_) =>
                                          ShopProvider(profile: profile),
                                      child: const ShopScreen(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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

class _ChessMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLightSquare;
  final VoidCallback onTap;

  const _ChessMenuButton({
    required this.icon,
    required this.label,
    required this.isLightSquare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isLightSquare ? const Color(0xFFF8F7F2) : const Color(0xFF0B0B10);
    final fgColor =
        isLightSquare ? const Color(0xFF0B0B10) : const Color(0xFFF8F7F2);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.all(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: fgColor),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
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
