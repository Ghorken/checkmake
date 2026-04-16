// lib/widgets/sprite_widget.dart

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checkmake/models/piece.dart';

enum SpriteAnimation { idle, attack }

const _frameCount = {
  SpriteAnimation.idle: 8,
  SpriteAnimation.attack: 6,
};

const _fps = {
  SpriteAnimation.idle: 8,
  SpriteAnimation.attack: 10,
};

// Maps SkinOwnership.skinId -> file suffix used in sprite sheet names
const _skinFileSuffix = <String, String>{
  'army_fire': 'fire',
  'pawn_shadow': 'shadow',
  'queen_golden': 'yellow',
  'army_ice': 'ice',
};

// ─────────────────────────────────────────────────────────────────────────────
// IMAGE CACHE
// ─────────────────────────────────────────────────────────────────────────────
final Map<String, Future<ui.Image?>> _imageCache = {};

Future<ui.Image?> _loadImage(String assetPath) {
  return _imageCache.putIfAbsent(assetPath, () async {
    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PATH BUILDER
// ─────────────────────────────────────────────────────────────────────────────
String _spritePath({
  required PieceType type,
  required PlayerSide side,
  required SpriteAnimation animation,
  required bool isHalfHp,
  required String? equippedSkin,
}) {
  final direction = side == PlayerSide.player1 ? 'back' : 'front';
  final anim = animation.name;
  final state = isHalfHp ? 'half' : 'full';
  final skin = equippedSkin != null
      ? (_skinFileSuffix[equippedSkin] ?? 'default')
      : 'default';
  return 'assets/images/pieces/${type.name}_${direction}_${anim}_${state}_$skin.png';
}

// ─────────────────────────────────────────────────────────────────────────────
// SPRITE WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class SpriteWidget extends StatefulWidget {
  final PieceType type;
  final PlayerSide side;
  final bool isHalfHp;
  final String? equippedSkin;
  final SpriteAnimation animation;
  final double size;

  const SpriteWidget({
    super.key,
    required this.type,
    required this.side,
    required this.isHalfHp,
    required this.animation,
    this.equippedSkin,
    this.size = 48,
  });

  @override
  State<SpriteWidget> createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  ui.Image? _image;
  int _frame = 0;
  Timer? _timer;
  String? _loadedPath;
  SpriteAnimation? _currentAnim;

  @override
  void initState() {
    super.initState();
    _startAnimation(widget.animation);
  }

  @override
  void didUpdateWidget(SpriteWidget old) {
    super.didUpdateWidget(old);
    final newPath = _buildPath(widget.animation);
    final oldPath = _buildPath(old.animation);
    if (newPath != oldPath || widget.animation != old.animation) {
      _startAnimation(widget.animation);
    }
  }

  String _buildPath(SpriteAnimation anim) => _spritePath(
        type: widget.type,
        side: widget.side,
        animation: anim,
        isHalfHp: widget.isHalfHp,
        equippedSkin: widget.equippedSkin,
      );

  void _startAnimation(SpriteAnimation anim) {
    _timer?.cancel();
    _frame = 0;
    _currentAnim = anim;

    final path = _buildPath(anim);
    if (_loadedPath != path) {
      _loadedPath = path;
      _loadImage(path).then((img) {
        if (!mounted || _loadedPath != path) return;
        setState(() => _image = img);
        _scheduleTimer(anim);
      });
    } else {
      _scheduleTimer(anim);
    }
  }

  void _scheduleTimer(SpriteAnimation anim) {
    _timer?.cancel();
    final count = _frameCount[anim]!;
    final interval = Duration(milliseconds: (1000 / _fps[anim]!).round());

    _timer = Timer.periodic(interval, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _frame++;
      if (_frame >= count) {
        t.cancel();
        if (anim != SpriteAnimation.idle) {
          // One-shot animations return to idle
          Future.microtask(() {
            if (mounted) _startAnimation(SpriteAnimation.idle);
          });
        } else {
          _frame = 0;
          _scheduleTimer(SpriteAnimation.idle);
        }
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _SpritePainter(
        image: image,
        frame: _frame,
        frameCount: _frameCount[_currentAnim ?? widget.animation]!,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPRITE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final int frame;
  final int frameCount;

  const _SpritePainter({
    required this.image,
    required this.frame,
    required this.frameCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = image.width / frameCount;
    const frameHeight = 192.0; // always 192px tall

    final src = Rect.fromLTWH(
      frame * frameWidth,
      0,
      frameWidth,
      frameHeight,
    );
    final dst = Offset.zero & size;
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
      old.frame != frame || old.image != image;
}
