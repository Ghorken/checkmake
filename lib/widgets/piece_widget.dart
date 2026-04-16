// lib/widgets/piece_widget.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/widgets/sprite_widget.dart';

// Medieval palette
const _gold = Color(0xFFD4AF37);
const _ironBlack = Color(0xFF0A0A0F);

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER PAINTER
// Medieval warrior shield style placeholders.
// Player1 pieces: blue-tinted shields (back view).
// Player2 pieces: red-tinted shields (front view, mirrored symbol).
// ─────────────────────────────────────────────────────────────────────────────
class PiecePlaceholderPainter extends CustomPainter {
  final PieceType type;
  final PlayerSide side;
  final bool isHalfHp;

  const PiecePlaceholderPainter({
    required this.type,
    required this.side,
    required this.isHalfHp,
  });

  static Color _pieceColor(PieceType type) => switch (type) {
        PieceType.pawn => const Color(0xFFD4C5A9), // sandstone
        PieceType.rook => const Color(0xFF4A6FA5), // steel blue
        PieceType.knight => const Color(0xFF8B4513), // saddle brown
        PieceType.bishop => const Color(0xFF6A5ACD), // purple vestment
        PieceType.queen => const Color(0xFFD4AF37), // gold crown
        PieceType.king => const Color(0xFFF3DE9B), // royal gold
        PieceType.fighter => const Color(0xFFB22222), // firebrick red
        PieceType.balista => const Color(0xFF5C4033), // dark wood
      };

  static String _symbol(PieceBaseType base) => switch (base) {
        PieceBaseType.pawn => '♟',
        PieceBaseType.rook => '♜',
        PieceBaseType.knight => '♞',
        PieceBaseType.bishop => '♝',
        PieceBaseType.queen => '♛',
        PieceBaseType.king => '♚',
      };

  @override
  void paint(Canvas canvas, Size size) {
    final def = pieceDefinitions[type]!;
    var color = _pieceColor(type);
    if (isHalfHp) color = color.withValues(alpha: 0.55);

    // Player identity colors
    final borderColor = side == PlayerSide.player1
        ? const Color(0xFF2B5798) // Steel blue
        : const Color(0xFF9B2335); // Blood red

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Shield-like hexagonal background
    final shieldPath = _createShieldPath(center, radius);
    canvas.drawPath(shieldPath, Paint()..color = color);

    // Dark inner gradient effect
    final innerGradient = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(shieldPath, innerGradient);

    // Thick border
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Second inner border (double-line medieval look)
    final innerShieldPath = _createShieldPath(center, radius - 3);
    canvas.drawPath(
      innerShieldPath,
      Paint()
        ..color = borderColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Battle damage effect at half HP
    if (isHalfHp) {
      _drawBattleDamage(canvas, size);
    }

    // Chess symbol
    final symbol = _symbol(def.baseType);
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: size.width * 0.5,
          color: Colors.white.withValues(alpha: isHalfHp ? 0.5 : 0.92),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = center.dx - textPainter.width / 2;
    final dy = center.dy - textPainter.height / 2;

    if (side == PlayerSide.player2) {
      canvas.save();
      canvas.translate(center.dx, 0);
      canvas.scale(-1, 1);
      canvas.translate(-center.dx, 0);
      textPainter.paint(canvas, Offset(dx, dy));
      canvas.restore();
    } else {
      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  Path _createShieldPath(Offset center, double radius) {
    // Rounded hexagonal shield shape
    final path = Path();
    const sides = 6;
    const startAngle = -math.pi / 2;
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + (2 * math.pi * i / sides);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle) * 1.05; // slightly taller
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawBattleDamage(Canvas canvas, Size size) {
    final crackPaint = Paint()
      ..color = const Color(0xFF6B0F1A).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Main crack
    final path1 = Path()
      ..moveTo(size.width * 0.35, size.height * 0.15)
      ..lineTo(size.width * 0.45, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.85);
    canvas.drawPath(path1, crackPaint);

    // Secondary crack
    final path2 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.7, size.height * 0.55);
    canvas.drawPath(path2, crackPaint..strokeWidth = 1.0);

    // Blood splatter dots
    final splatPaint = Paint()
      ..color = const Color(0xFF6B0F1A).withValues(alpha: 0.4);
    canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.3), 1.5, splatPaint);
    canvas.drawCircle(
        Offset(size.width * 0.35, size.height * 0.7), 1.0, splatPaint);
  }

  @override
  bool shouldRepaint(PiecePlaceholderPainter old) =>
      old.type != type || old.side != side || old.isHalfHp != isHalfHp;
}

// ─────────────────────────────────────────────────────────────────────────────
// PIECE WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class PieceWidget extends StatefulWidget {
  final Piece piece;
  final double size;
  final bool showStats;
  final bool isSelected;
  final SpriteAnimation animation;
  final int hitSignal;

  const PieceWidget({
    super.key,
    required this.piece,
    this.size = 48,
    this.showStats = false,
    this.isSelected = false,
    this.animation = SpriteAnimation.idle,
    this.hitSignal = 0,
  });

  @override
  State<PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<PieceWidget> {
  static const _blinkFrames = <double>[0.25, 1.0, 0.25, 1.0];
  static const _blinkStep = Duration(milliseconds: 85);
  double _opacity = 1.0;
  Timer? _blinkTimer;
  int _blinkIndex = 0;

  @override
  void didUpdateWidget(covariant PieceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hitSignal != oldWidget.hitSignal && widget.hitSignal > 0) {
      _startBlink();
    }
  }

  void _startBlink() {
    _blinkTimer?.cancel();
    _blinkIndex = 0;
    setState(() => _opacity = _blinkFrames[_blinkIndex]);

    _blinkTimer = Timer.periodic(_blinkStep, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _blinkIndex++;
      if (_blinkIndex >= _blinkFrames.length) {
        timer.cancel();
        setState(() => _opacity = 1.0);
        return;
      }
      setState(() => _opacity = _blinkFrames[_blinkIndex]);
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final piece = widget.piece;
    final size = widget.size;
    final showStats = widget.showStats;
    final isSelected = widget.isSelected;
    final animation = widget.animation;

    final visualLayer = Stack(
      children: [
        // ── Sprite sheet animation ──────────────────────────────
        Positioned.fill(
          child: SpriteWidget(
            type: piece.type,
            side: piece.side,
            isHalfHp: piece.stats.isHalfHp,
            equippedSkin: piece.equippedSkin,
            animation: animation,
            size: size,
          ),
        ),

        // ── Selection glow ──────────────────────────────────────
        if (isSelected)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: _gold.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
      ],
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 70),
            child: visualLayer,
          ),

          // ── HP Bar (blood-themed) ──────────────────────────────
          if (showStats)
            Positioned(
              bottom: 0,
              left: 2,
              right: 2,
              child: _HpBar(
                current: piece.stats.currentHp,
                max: piece.stats.maxHp,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HP BAR (blood-themed)
// ─────────────────────────────────────────────────────────────────────────────
class _HpBar extends StatelessWidget {
  final int current;
  final int max;

  const _HpBar({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = (current / max).clamp(0.0, 1.0);

    // Color transitions: green -> yellow -> orange -> red based on HP
    Color barColor;
    if (ratio > 0.6) {
      barColor = const Color(0xFF2E7D32); // Forest green
    } else if (ratio > 0.35) {
      barColor = const Color(0xFFCD7F32); // Bronze/amber warning
    } else {
      barColor = const Color(0xFF8B1E2D); // Blood red critical
    }

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: _ironBlack.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                barColor,
                barColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
