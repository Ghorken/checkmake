import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/models/achievement.dart';
import 'package:checkmake/models/player_profile.dart';

const _gold = Color(0xFFD4AF37);
const _steelBlue = Color(0xFF2B5798);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);
const _crimson = Color(0xFF8B1E2D);

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerProfile>();

    final unlocked = allAchievements
        .where((a) => profile.unlockedAchievements.contains(a.id))
        .toList();
    final locked = allAchievements
        .where((a) => !profile.unlockedAchievements.contains(a.id))
        .toList();

    return Scaffold(
      backgroundColor: _ironBlack,
      appBar: AppBar(
        backgroundColor: _darkStone.withValues(alpha: 0.95),
        title: Text(
          'Imprese',
          style: GoogleFonts.cinzelDecorative(color: _gold, fontSize: 18),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _darkStone.withValues(alpha: 0.3),
              _ironBlack,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (unlocked.isNotEmpty) ...[
              _SectionHeader(
                label: 'Sbloccate (${unlocked.length}/${allAchievements.length})',
                icon: Icons.emoji_events,
                color: _gold,
              ),
              const SizedBox(height: 8),
              ...unlocked.map((def) => _AchievementCard(
                    def: def,
                    unlocked: true,
                    profile: profile,
                  )),
              const SizedBox(height: 16),
            ],
            if (locked.isNotEmpty) ...[
              _SectionHeader(
                label: 'Da sbloccare',
                icon: Icons.lock,
                color: _parchment.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              ...locked.map((def) => _AchievementCard(
                    def: def,
                    unlocked: false,
                    profile: profile,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withValues(alpha: 0.3))),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementDefinition def;
  final bool unlocked;
  final PlayerProfile profile;

  const _AchievementCard({
    required this.def,
    required this.unlocked,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final hasSkinReward = def.skinReward != null;
    final skinOwned = hasSkinReward &&
        profile.ownedSkins.any((s) => s.skinId == def.skinReward!.skinId);
    final skinEquipped = skinOwned &&
        profile.ownedSkins
            .any((s) => s.skinId == def.skinReward!.skinId && s.isEquipped);

    return Card(
      color: _darkStone,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: unlocked
              ? _gold.withValues(alpha: 0.4)
              : _parchment.withValues(alpha: 0.1),
        ),
      ),
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: unlocked
                      ? _gold.withValues(alpha: 0.15)
                      : _parchment.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: unlocked
                        ? _gold.withValues(alpha: 0.5)
                        : _parchment.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  unlocked ? Icons.emoji_events : Icons.lock,
                  color: unlocked ? _gold : _parchment.withValues(alpha: 0.3),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.name,
                      style: GoogleFonts.cinzel(
                        color: unlocked ? _parchment : _parchment.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      def.description,
                      style: GoogleFonts.lora(
                        color: _parchment.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (hasSkinReward) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.palette,
                              size: 11,
                              color: unlocked
                                  ? _gold
                                  : _parchment.withValues(alpha: 0.3)),
                          const SizedBox(width: 4),
                          Text(
                            'Skin: ${def.skinReward!.name}',
                            style: GoogleFonts.cinzel(
                              color: unlocked
                                  ? _gold
                                  : _parchment.withValues(alpha: 0.3),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Equip button (only for unlocked achievements with skin reward)
              if (unlocked && hasSkinReward && skinOwned) ...[
                const SizedBox(width: 8),
                skinEquipped
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _steelBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                              color: _steelBlue.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'Equipaggiata',
                          style: GoogleFonts.cinzel(
                              color: _steelBlue, fontSize: 10),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () =>
                            profile.equipSkin(def.skinReward!.skinId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        child: Text(
                          'Equipaggia',
                          style: GoogleFonts.cinzel(
                            color: _ironBlack,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
              if (unlocked && !hasSkinReward)
                Icon(Icons.check_circle,
                    color: _gold.withValues(alpha: 0.6), size: 20),
              if (!unlocked)
                Icon(Icons.radio_button_unchecked,
                    color: _crimson.withValues(alpha: 0.2), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
