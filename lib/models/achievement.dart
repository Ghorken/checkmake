import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/player_profile.dart';

class AchievementSkinReward {
  final String skinId;
  final String name;
  final PieceType? targetPiece;

  const AchievementSkinReward({
    required this.skinId,
    required this.name,
    this.targetPiece,
  });
}

class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final AchievementSkinReward? skinReward;
  final bool Function(PlayerProfile) condition;

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    this.skinReward,
  });
}

final List<AchievementDefinition> allAchievements = [
  AchievementDefinition(
    id: 'first_win',
    name: 'Prima Vittoria',
    description: 'Vinci la tua prima partita.',
    condition: (p) => p.wins >= 1,
  ),
  AchievementDefinition(
    id: 'veteran',
    name: 'Veterano',
    description: 'Vinci 5 partite.',
    condition: (p) => p.wins >= 5,
    skinReward: const AchievementSkinReward(
      skinId: 'army_fire',
      name: 'Armata del Fuoco',
    ),
  ),
  AchievementDefinition(
    id: 'resilient',
    name: 'Resistente',
    description: 'Disputa almeno 10 partite.',
    condition: (p) => p.wins + p.losses >= 10,
  ),
  AchievementDefinition(
    id: 'blacksmith',
    name: "L'Armaiolo",
    description: 'Potenzia una statistica di qualsiasi pezzo fino al livello 3.',
    condition: (p) => p.upgradeLevels.values.any(
      (u) => u.hpLevel >= 3 || u.attackLevel >= 3 || u.valueLevel >= 3,
    ),
    skinReward: const AchievementSkinReward(
      skinId: 'pawn_shadow',
      name: 'Pedone Ombra',
      targetPiece: PieceType.pawn,
    ),
  ),
  AchievementDefinition(
    id: 'condottiero',
    name: 'Condottiero',
    description: 'Vinci 15 partite.',
    condition: (p) => p.wins >= 15,
    skinReward: const AchievementSkinReward(
      skinId: 'army_ice',
      name: 'Armata del Ghiaccio',
    ),
  ),
  AchievementDefinition(
    id: 'treasurer',
    name: 'Tesoriere',
    description: 'Accumula 3000 monete.',
    condition: (p) => p.coins >= 3000,
  ),
  AchievementDefinition(
    id: 'grand_condottiero',
    name: 'Il Grande Condottiero',
    description: 'Vinci 30 partite.',
    condition: (p) => p.wins >= 30,
    skinReward: const AchievementSkinReward(
      skinId: 'queen_golden',
      name: 'Regina Dorata',
      targetPiece: PieceType.queen,
    ),
  ),
  AchievementDefinition(
    id: 'collector',
    name: 'Collezionista',
    description: 'Sblocca almeno 8 tipi di pezzo diversi.',
    condition: (p) => p.unlockedPieces.length >= 8,
  ),
];

void tryUnlockAchievements(PlayerProfile profile) {
  for (final def in allAchievements) {
    if (!profile.unlockedAchievements.contains(def.id) &&
        def.condition(profile)) {
      final skinReward = def.skinReward;
      profile.unlockAchievement(
        def.id,
        skinReward: skinReward != null
            ? SkinOwnership(
                skinId: skinReward.skinId,
                name: skinReward.name,
                targetPiece: skinReward.targetPiece,
              )
            : null,
      );
    }
  }
}
