import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
    
    // Theme colors
    const brightGold = Color(0xFFFFD700);
    const darkStone = Color(0xFF2C3E50);
    const parchmentWhite = Color(0xFFFDF5E6);
    const imperialRed = Color(0xFFB22222);

    return Scaffold(
      backgroundColor: parchmentWhite,
      body: Stack(
        children: [
          // Regal Checkboard Background overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _BackgroundPainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Title
                Text(
                  l.appTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.macondo(
                    color: darkStone,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      const Shadow(color: brightGold, blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

                Text(
                  l.appSubtitle,
                  style: GoogleFonts.cinzel(
                    color: imperialRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                
                const SizedBox(height: 30),

                // Player Stats Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: darkStone,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: brightGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat('🪙', '${profile.coins}', l.statCoins),
                      Container(height: 40, width: 1, color: brightGold.withValues(alpha: 0.3)),
                      _Stat('🏆', '${profile.wins}', l.statWins),
                      Container(height: 40, width: 1, color: brightGold.withValues(alpha: 0.3)),
                      _Stat('💀', '${profile.losses}', l.statLosses),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),

                const SizedBox(height: 30),

                // The Checkerboard Menu
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: 12, // 3x4 grid
                          itemBuilder: (context, index) {
                            // Alternating colors for checkerboard
                            final isLightSquare = (index ~/ 3 + index % 3) % 2 == 0;
                            
                            // Map buttons to specific squares
                            Widget tileContent = const SizedBox.shrink();
                            
                            if (index == 1) {
                              tileContent = _MenuButton(
                                icon: Icons.sports_esports,
                                label: l.btnPlay,
                                isLightSquare: isLightSquare,
                                onTap: () => _startGame(context, profile),
                              );
                            } else if (index == 4) {
                              tileContent = _MenuButton(
                                icon: Icons.wifi,
                                label: l.btnMultiplayer,
                                isLightSquare: isLightSquare,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider<PlayerProfile>.value(
                                      value: profile,
                                      child: const MatchmakingScreen(),
                                    ),
                                  ),
                                ),
                              );
                            } else if (index == 7) {
                              tileContent = _MenuButton(
                                icon: Icons.shield,
                                label: l.btnBuildArmy,
                                isLightSquare: isLightSquare,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider<PlayerProfile>.value(
                                      value: profile,
                                      child: const ArmyBuilderScreen(),
                                    ),
                                  ),
                                ),
                              );
                            } else if (index == 10) {
                              tileContent = _MenuButton(
                                icon: Icons.store,
                                label: l.btnShop,
                                isLightSquare: isLightSquare,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (_) => ShopProvider(profile: profile),
                                      child: const ShopScreen(),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Decorative empty tile
                              tileContent = _DecorativeTile(
                                isLightSquare: isLightSquare,
                                index: index,
                              );
                            }

                            return tileContent.animate()
                                .fadeIn(delay: (800 + index * 50).ms, duration: 400.ms)
                                .scale(begin: const Offset(0.8, 0.8));
                          },
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
      'name': 'Guerriero',
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GameProvider(
            myProfile: myProfile,
            opponentProfile: opponent,
            hotseatMode: true,
            startPaused: true,
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
  final bool isLightSquare;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.isLightSquare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // "Bright Regal" colors
    final darkStone = const Color(0xFF2C3E50);
    final parchmentWhite = const Color(0xFFFDF5E6);
    final shadowGold = const Color(0xFFB8860B);

    final bgColor = isLightSquare ? parchmentWhite : darkStone;
    final fgColor = isLightSquare ? darkStone : brightGold;
    final borderColor = shadowGold;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: shadowGold.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: fgColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.macondo(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get brightGold => const Color(0xFFFFD700);
}

class _DecorativeTile extends StatelessWidget {
  final bool isLightSquare;
  final int index;

  const _DecorativeTile({
    required this.isLightSquare,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final darkStone = const Color(0xFF2C3E50);
    final parchmentWhite = const Color(0xFFFDF5E6);
    final shadowGold = const Color(0xFFB8860B);

    final bgColor = isLightSquare ? parchmentWhite : darkStone;
    
    // Choose a random-looking icon based on index for variety
    final icons = [Icons.fort, Icons.security, Icons.account_balance, Icons.gavel, Icons.flag];
    final IconData decorIcon = icons[index % icons.length];
    
    // Low opacity for decoration
    final iconColor = isLightSquare 
      ? darkStone.withValues(alpha: 0.05) 
      : Colors.white.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: shadowGold.withValues(alpha: 0.3), width: 1),
      ),
      child: Center(
        child: Icon(decorIcon, size: 48, color: iconColor),
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
  Widget build(BuildContext context) {
    const brightGold = Color(0xFFFFD700);
    const parchmentWhite = Color(0xFFFDF5E6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$emoji $value',
          style: GoogleFonts.macondo(
            color: brightGold, 
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: parchmentWhite, 
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const darkStone = Color(0xFF2C3E50);
    final paint = Paint()
      ..color = darkStone
      ..style = PaintingStyle.fill;

    // Draw a subtle checkerboard pattern across the entire background
    const double squareSize = 80.0;
    
    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        bool isDark = ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        if (isDark) {
          canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
