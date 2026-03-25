// lib/widgets/piece_widget.dart

import 'package:flutter/material.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER PAINTER
// Disegna placeholder colorati finché non sono disponibili gli asset reali.
// I pezzi del giocatore (player1) mostrano il simbolo normale → di schiena.
// I pezzi dell'avversario (player2) mostrano il simbolo specchiato → di fronte.
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
        PieceType.pawn => const Color(0xFFF8F7F2),
        PieceType.rook => const Color(0xFF1E3A8A),
        PieceType.knight => const Color(0xFF8B1E2D),
        PieceType.bishop => const Color(0xFF274690),
        PieceType.queen => const Color(0xFFD4AF37),
        PieceType.king => const Color(0xFFF3DE9B),
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
    if (isHalfHp) color = color.withValues(alpha: 0.6);

    // Bordo blu = player1 (giocatore), rosso = player2 (avversario)
    final borderColor = side == PlayerSide.player1
        ? const Color(0xFF1E3A8A)
        : const Color(0xFF8B1E2D);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Sfondo circolare
    canvas.drawCircle(center, radius, Paint()..color = color);

    // Bordo colorato
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Crepa a metà vita
    if (isHalfHp) {
      final crackPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(size.width * 0.4, size.height * 0.2)
        ..lineTo(size.width * 0.55, size.height * 0.5)
        ..lineTo(size.width * 0.35, size.height * 0.8);
      canvas.drawPath(path, crackPaint);
    }

    // Simbolo scacchi: specchiato orizzontalmente per player2 (di fronte)
    final symbol = _symbol(def.baseType);
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: size.width * 0.55,
          color: Colors.white.withValues(alpha: isHalfHp ? 0.6 : 0.95),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = center.dx - textPainter.width / 2;
    final dy = center.dy - textPainter.height / 2;

    if (side == PlayerSide.player2) {
      // Specchia orizzontalmente: trasla al centro, scala -1 sull'asse X, ritrasla
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

  @override
  bool shouldRepaint(PiecePlaceholderPainter old) =>
      old.type != type || old.side != side || old.isHalfHp != isHalfHp;
}

// ─────────────────────────────────────────────────────────────────────────────
// PIECE WIDGET
// Carica piece.imagePath (asset PNG); se manca usa il placeholder.
//
// Convenzione asset:
//   assets/images/pieces/{type}_{perspective}_{state}.png
//     perspective = 'back'  → player1 (di schiena)
//                = 'front' → player2 (di fronte)
//     state       = 'full' | 'half'
//
// Esempi:
//   assets/images/pieces/pawn_back_full.png
//   assets/images/pieces/pawn_front_half.png
//   assets/images/pieces/queen_back_full.png
// ─────────────────────────────────────────────────────────────────────────────
class PieceWidget extends StatelessWidget {
  final Piece piece;
  final double size;
  final bool showStats; // mostra la barra HP solo per i propri pezzi
  final bool isSelected;

  const PieceWidget({
    super.key,
    required this.piece,
    this.size = 48,
    this.showStats = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // ── Immagine principale ──────────────────────────────────────────
          // Prova a caricare l'asset; se non esiste (ancora) usa il placeholder.
          Positioned.fill(
            child: Image.asset(
              piece.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            ),
          ),

          // ── Bordo selezione ──────────────────────────────────────────────
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),

          // ── Barra HP ─────────────────────────────────────────────────────
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

  Widget _buildPlaceholder() => CustomPaint(
        painter: PiecePlaceholderPainter(
          type: piece.type,
          side: piece.side,
          isHalfHp: piece.stats.isHalfHp,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
class _HpBar extends StatelessWidget {
  final int current;
  final int max;

  const _HpBar({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = current / max;
    const color = Colors.green;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B10).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
