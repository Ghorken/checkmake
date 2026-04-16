// lib/widgets/game_board_widget.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/widgets/piece_widget.dart';
import 'package:checkmake/widgets/sprite_widget.dart';

// Medieval board palette
const _lightSquare = Color(0xFFD4C5A9); // Worn parchment / sandstone
const _darkSquare = Color(0xFF3B2415); // Dark oak / burnt wood
const _gold = Color(0xFFD4AF37);
const _crimson = Color(0xFF8B1E2D);
const _battleRed = Color(0xFF6B0F1A);

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final rotateForOnlinePlayer2 =
        !game.hotseatMode && game.localSide == PlayerSide.player2;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          // Thick wooden frame feel
          border: Border.all(color: _gold, width: 3),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _crimson.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Stack(
            children: [
              // Board background with stone texture feel
              Positioned.fill(
                child: CustomPaint(painter: _BoardBackgroundPainter()),
              ),
              // Grid
              Transform.rotate(
                angle: rotateForOnlinePlayer2 ? math.pi : 0,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final row = index ~/ 8;
                    final col = index % 8;
                    final pos = Position(row, col);
                    return _BoardCell(position: pos);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOARD BACKGROUND PAINTER (stone texture)
// ═══════════════════════════════════════════════════════════════════════════════
class _BoardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base dark fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1A1208),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOARD CELL
// ═══════════════════════════════════════════════════════════════════════════════
class _BoardCell extends StatelessWidget {
  final Position position;

  const _BoardCell({required this.position});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final piece = game.board.getPiece(position);
    final isLight = (position.row + position.col) % 2 == 0;
    final isSelected = game.selectedPosition == position;
    final isValidMove = game.validMoves.contains(position);
    final isMyPiece = piece?.side == game.interactiveSide;
    final isEnemyTarget = isValidMove && piece != null;

    Color cellColor;
    if (isSelected) {
      cellColor = _gold.withValues(alpha: 0.75);
    } else if (isValidMove) {
      cellColor = isEnemyTarget
          ? _battleRed.withValues(alpha: 0.65)
          : (isLight
              ? _lightSquare.withValues(alpha: 0.85)
              : _darkSquare.withValues(alpha: 0.85));
    } else {
      cellColor = isLight ? _lightSquare : _darkSquare;
    }

    return GestureDetector(
      onTap: () => game.selectPosition(position),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          // Subtle inner border for stone-carved feel
          border: isSelected
              ? Border.all(color: _gold.withValues(alpha: 0.8), width: 1.5)
              : isEnemyTarget
                  ? Border.all(
                      color: _battleRed.withValues(alpha: 0.6), width: 1)
                  : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Valid move indicator — pallino giallo su casella vuota
            if (isValidMove && piece == null)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withValues(alpha: 0.55),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

            // Piece
            if (piece != null)
              Padding(
                padding: const EdgeInsets.all(2),
                child: PieceWidget(
                  piece: piece,
                  size: double.infinity,
                  showStats: isMyPiece,
                  isSelected: isSelected,
                  hitSignal: game.hitSignalFor(position),
                  animation: game.lastAttackPos == position
                      ? SpriteAnimation.attack
                      : SpriteAnimation.idle,
                ),
              ),

            // Combat move indicator — pallino rosso sopra il pezzo nemico
            if (isEnemyTarget)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _battleRed.withValues(alpha: 0.9),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _battleRed.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
