// lib/widgets/game_board_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/models/board.dart';
import 'package:checkmake/providers/game_provider.dart';
import 'package:checkmake/widgets/piece_widget.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37), width: 4),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF8B1E2D).withValues(alpha: 0.2),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
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
      ),
    );
  }
}

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

    Color cellColor;
    if (isSelected) {
      cellColor = const Color(0xFFD4AF37).withValues(alpha: 0.8);
    } else if (isValidMove) {
      cellColor = piece != null
          ? const Color(0xFF8B1E2D)
              .withValues(alpha: 0.55) // casella con nemico
          : const Color(0xFF1E3A8A).withValues(alpha: 0.45);
    } else {
      cellColor = isLight ? const Color(0xFFF8F7F2) : const Color(0xFF1E3A8A);
    }

    return GestureDetector(
      onTap: () => game.selectPosition(position),
      child: Container(
        color: cellColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Indicatore mossa valida
            if (isValidMove && piece == null)
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.75),
                ),
              ),

            // Pezzo
            if (piece != null)
              Padding(
                padding: const EdgeInsets.all(2),
                child: PieceWidget(
                  piece: piece,
                  size: double.infinity,
                  showStats: isMyPiece,
                  isSelected: isSelected,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
