// lib/screens/main_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/providers/shop_provider.dart';
import 'package:checkmake/screens/game_screen.dart';
import 'package:checkmake/screens/shop_screen.dart';
import 'package:checkmake/screens/army_builder_screen.dart';
import 'package:checkmake/screens/matchmaking_screen.dart';

// Medieval palette
const _gold = Color(0xFFD4AF37);
const _crimson = Color(0xFF8B1E2D);
const _bloodRed = Color(0xFF6B0F1A);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);
const _lightSquare = Color(0xFFD4C5A9);
const _darkSquare = Color(0xFF2A1F1A);

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerProfile>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _ironBlack,
      body: Stack(
        children: [
          // Full checkerboard background
          Positioned.fill(
            child: CustomPaint(painter: _CheckerboardPainter()),
          ),
          // Dark vignette overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    _ironBlack.withValues(alpha: 0.6),
                    _ironBlack.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Top-down dramatic gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _bloodRed.withValues(alpha: 0.25),
                    Colors.transparent,
                    _darkStone.withValues(alpha: 0.4),
                    _bloodRed.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Decorative border lines
          Positioned.fill(
            child: CustomPaint(painter: _MedievalBorderPainter()),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Crossed swords decorative line
                _buildDecorativeLine(),
                const SizedBox(height: 12),
                // Title
                Text(
                  l.appTitle.toUpperCase(),
                  style: GoogleFonts.cinzelDecorative(
                    color: _gold,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    shadows: [
                      const Shadow(
                        color: Color(0xFF000000),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                      Shadow(
                        color: _crimson.withValues(alpha: 0.8),
                        blurRadius: 30,
                      ),
                      Shadow(
                        color: _gold.withValues(alpha: 0.3),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  l.appSubtitle.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    color: _parchment.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDecorativeLine(),
                const SizedBox(height: 16),

                // Player stats banner
                _StatsBar(profile: profile, l: l),

                // Menu buttons grid (2x2 checkerboard)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            children: [
                              _MedievalMenuTile(
                                icon: Icons.sports_esports,
                                secondaryIcon: '⚔',
                                label: l.btnPlay,
                                isLightSquare: true,
                                onTap: () => _startGame(context, profile),
                              ),
                              _MedievalMenuTile(
                                icon: Icons.wifi,
                                secondaryIcon: '🏰',
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
                              _MedievalMenuTile(
                                icon: Icons.shield,
                                secondaryIcon: '🛡',
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
                              _MedievalMenuTile(
                                icon: Icons.store,
                                secondaryIcon: '🪙',
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

                // Bottom decorative element
                _buildDecorativeLine(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return SizedBox(
      width: 200,
      height: 16,
      child: CustomPaint(painter: _DecorativeLinePainter()),
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
            startPaused: true,
          ),
          child: const GameScreen(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHECKERBOARD BACKGROUND PAINTER
// ═══════════════════════════════════════════════════════════════════════════════
class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareCount = 10; // number of squares across
    final squareSize = size.width / squareCount;
    final rows = (size.height / squareSize).ceil() + 1;

    final lightPaint = Paint()..color = _lightSquare.withValues(alpha: 0.12);
    final darkPaint = Paint()..color = _darkSquare.withValues(alpha: 0.25);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < squareCount; c++) {
        final isLight = (r + c) % 2 == 0;
        final rect = Rect.fromLTWH(
          c * squareSize,
          r * squareSize,
          squareSize,
          squareSize,
        );
        canvas.drawRect(rect, isLight ? lightPaint : darkPaint);

        // Subtle worn texture effect on some squares
        if ((r * squareCount + c) % 7 == 0) {
          final wornPaint = Paint()
            ..color = _gold.withValues(alpha: 0.03)
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, wornPaint);
        }
      }
    }

    // Grid lines for stone-cut feel
    final linePaint = Paint()
      ..color = _gold.withValues(alpha: 0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (int r = 0; r <= rows; r++) {
      canvas.drawLine(
        Offset(0, r * squareSize),
        Offset(size.width, r * squareSize),
        linePaint,
      );
    }
    for (int c = 0; c <= squareCount; c++) {
      canvas.drawLine(
        Offset(c * squareSize, 0),
        Offset(c * squareSize, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDIEVAL BORDER PAINTER
// ═══════════════════════════════════════════════════════════════════════════════
class _MedievalBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = _gold.withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Outer border
    final outerRect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRect(outerRect, borderPaint);

    // Corner ornaments
    final cornerPaint = Paint()
      ..color = _gold.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const cornerSize = 24.0;
    // Top-left
    _drawCornerOrnament(canvas, 8, 8, cornerSize, cornerPaint);
    // Top-right
    _drawCornerOrnament(
        canvas, size.width - 8, 8, cornerSize, cornerPaint,
        flipX: true);
    // Bottom-left
    _drawCornerOrnament(
        canvas, 8, size.height - 8, cornerSize, cornerPaint,
        flipY: true);
    // Bottom-right
    _drawCornerOrnament(
        canvas, size.width - 8, size.height - 8, cornerSize, cornerPaint,
        flipX: true, flipY: true);
  }

  void _drawCornerOrnament(
      Canvas canvas, double x, double y, double s, Paint paint,
      {bool flipX = false, bool flipY = false}) {
    final dx = flipX ? -1.0 : 1.0;
    final dy = flipY ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(x, y + s * dy)
      ..lineTo(x, y)
      ..lineTo(x + s * dx, y);
    canvas.drawPath(path, paint);
    // Inner diagonal
    canvas.drawLine(
      Offset(x + 4 * dx, y + 4 * dy),
      Offset(x + (s - 4) * dx, y + (s - 4) * dy),
      paint..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// DECORATIVE LINE PAINTER (sword-like horizontal divider)
// ═══════════════════════════════════════════════════════════════════════════════
class _DecorativeLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gold.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cy = size.height / 2;
    final cx = size.width / 2;

    // Left line
    canvas.drawLine(Offset(0, cy), Offset(cx - 12, cy), paint);
    // Right line
    canvas.drawLine(Offset(cx + 12, cy), Offset(size.width, cy), paint);

    // Diamond in center
    final diamondPaint = Paint()
      ..color = _gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final diamond = Path()
      ..moveTo(cx, cy - 5)
      ..lineTo(cx + 8, cy)
      ..lineTo(cx, cy + 5)
      ..lineTo(cx - 8, cy)
      ..close();
    canvas.drawPath(diamond, diamondPaint);

    // Small diamonds at ends
    for (final offset in [16.0, size.width - 16.0]) {
      final small = Path()
        ..moveTo(offset, cy - 3)
        ..lineTo(offset + 4, cy)
        ..lineTo(offset, cy + 3)
        ..lineTo(offset - 4, cy)
        ..close();
      canvas.drawPath(small, Paint()..color = _gold.withValues(alpha: 0.3));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _StatsBar extends StatelessWidget {
  final PlayerProfile profile;
  final AppLocalizations l;
  const _StatsBar({required this.profile, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: _ironBlack.withValues(alpha: 0.85),
        border: Border.all(color: _gold.withValues(alpha: 0.35), width: 1.5),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(icon: Icons.monetization_on, value: '${profile.coins}', label: l.statCoins),
          _divider(),
          _StatItem(icon: Icons.emoji_events, value: '${profile.wins}', label: l.statWins),
          _divider(),
          _StatItem(icon: Icons.dangerous, value: '${profile.losses}', label: l.statLosses),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: _gold.withValues(alpha: 0.2),
      );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _gold, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.cinzel(
                  color: _gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.cinzel(
              color: _parchment.withValues(alpha: 0.5),
              fontSize: 8,
              letterSpacing: 1.5,
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDIEVAL MENU TILE (checkerboard-style button)
// ═══════════════════════════════════════════════════════════════════════════════
class _MedievalMenuTile extends StatelessWidget {
  final IconData icon;
  final String secondaryIcon;
  final String label;
  final bool isLightSquare;
  final VoidCallback onTap;

  const _MedievalMenuTile({
    required this.icon,
    required this.secondaryIcon,
    required this.label,
    required this.isLightSquare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isLightSquare
        ? _lightSquare.withValues(alpha: 0.9)
        : _darkSquare.withValues(alpha: 0.95);
    final fgColor = isLightSquare ? _ironBlack : _parchment;
    final accentColor = isLightSquare ? _crimson : _gold;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: _gold.withValues(alpha: 0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              if (!isLightSquare)
                BoxShadow(
                  color: _crimson.withValues(alpha: 0.1),
                  blurRadius: 16,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Corner decorations
              Positioned(
                top: 4,
                left: 4,
                child: _CornerDecoration(color: accentColor),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
                  child: _CornerDecoration(color: accentColor),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0),
                  child: _CornerDecoration(color: accentColor),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1.0, -1.0, 1.0),
                  child: _CornerDecoration(color: accentColor),
                ),
              ),
              // Background secondary icon (watermark)
              Positioned(
                right: 8,
                bottom: 6,
                child: Text(
                  secondaryIcon,
                  style: TextStyle(
                    fontSize: 28,
                    color: fgColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: accentColor),
                    const SizedBox(height: 8),
                    Text(
                      label.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: fgColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  final Color color;
  const _CornerDecoration({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(
        painter: _CornerPainter(color: color.withValues(alpha: 0.4)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
