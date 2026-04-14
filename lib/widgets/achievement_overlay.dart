// lib/widgets/achievement_overlay.dart

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/models/achievement.dart';
import 'package:checkmake/models/player_profile.dart';

const _gold = Color(0xFFD4AF37);
const _darkStone = Color(0xFF1A1A2E);
const _parchment = Color(0xFFF0E6D3);

// ─────────────────────────────────────────────────────────────────────────────
// OVERLAY LISTENER
// Va inserito tramite MaterialApp.builder per avere accesso all'Overlay globale.
// ─────────────────────────────────────────────────────────────────────────────
class AchievementToastOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  const AchievementToastOverlay({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<AchievementToastOverlay> createState() =>
      _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<AchievementToastOverlay> {
  PlayerProfile? _profile;
  final Queue<String> _queue = Queue();
  bool _showing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.read<PlayerProfile>();
    if (profile != _profile) {
      _profile?.removeListener(_onProfileChanged);
      _profile = profile;
      _profile!.addListener(_onProfileChanged);
    }
  }

  @override
  void dispose() {
    _profile?.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final profile = _profile;
    if (profile == null) return;
    while (profile.hasPendingAchievementToasts) {
      _queue.add(profile.consumeAchievementToast()!);
    }
    if (!_showing) _processQueue();
  }

  void _processQueue() {
    if (_queue.isEmpty || !mounted) return;
    _showing = true;

    final id = _queue.removeFirst();
    final def = allAchievements.firstWhere(
      (a) => a.id == id,
      orElse: () => AchievementDefinition(
        id: id,
        name: id,
        description: '',
        condition: (_) => false,
      ),
    );

    final overlay =
        widget.navigatorKey?.currentState?.overlay ?? Overlay.maybeOf(context);
    if (overlay == null) {
      _showing = false;
      // Se l'overlay non è ancora disponibile (es. durante bootstrap),
      // riprova al frame successivo senza perdere la coda.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_showing) _processQueue();
      });
      return;
    }
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AchievementToastBanner(
        achievement: def,
        onDone: () {
          entry.remove();
          _showing = false;
          // Piccola pausa prima del prossimo toast
          Future.delayed(const Duration(milliseconds: 300), _processQueue);
        },
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────
// TOAST BANNER (animato, slide dall'alto)
// ─────────────────────────────────────────────────────────────────────────────
class _AchievementToastBanner extends StatefulWidget {
  final AchievementDefinition achievement;
  final VoidCallback onDone;

  const _AchievementToastBanner({
    required this.achievement,
    required this.onDone,
  });

  @override
  State<_AchievementToastBanner> createState() =>
      _AchievementToastBannerState();
}

class _AchievementToastBannerState extends State<_AchievementToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _ctrl.forward().then((_) {
      // Mostra per 2.8s poi esce
      Future.delayed(const Duration(milliseconds: 2800), () {
        if (!mounted) return;
        _ctrl
            .reverse()
            .then((_) { if (mounted) widget.onDone(); });
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _darkStone,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _gold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icona trofeo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold, width: 1.5),
                    ),
                    child: const Icon(Icons.emoji_events,
                        color: _gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Testo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Impresa sbloccata!',
                          style: GoogleFonts.cinzel(
                            color: _gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.achievement.name,
                          style: GoogleFonts.cinzelDecorative(
                            color: _parchment,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.achievement.description.isNotEmpty)
                          Text(
                            widget.achievement.description,
                            style: GoogleFonts.lora(
                              color: _parchment.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
