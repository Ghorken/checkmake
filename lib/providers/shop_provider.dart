// lib/providers/shop_provider.dart

import 'package:flutter/foundation.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';

class ShopSkinItem {
  final String skinId;
  final String name;
  final String description;
  final int cost;
  final PieceType? targetPiece; // null = skin intera armata

  const ShopSkinItem({
    required this.skinId,
    required this.name,
    required this.description,
    required this.cost,
    this.targetPiece,
  });
}

// Catalogo skin disponibili - espandibile facilmente
const List<ShopSkinItem> availableSkins = [];

class ShopProvider extends ChangeNotifier {
  final PlayerProfile profile;

  ShopProvider({required this.profile});

  // ===== SBLOCCO PEZZI =====
  bool canUnlock(PieceType type) {
    final def = pieceDefinitions[type];
    if (def == null || !def.isUnlockable) return false;
    if (profile.hasPiece(type)) return false;
    return profile.coins >= def.unlockCost;
  }

  bool unlockPiece(PieceType type) {
    final def = pieceDefinitions[type];
    if (def == null || !canUnlock(type)) return false;
    if (!profile.spendCoins(def.unlockCost)) return false;
    profile.unlockedPieces.add(type);
    notifyListeners();
    return true;
  }

  // ===== UPGRADES =====
  int getUpgradeCost(PieceType type, String stat) {
    final def = pieceDefinitions[type];
    if (def == null) return 0;
    final levels = profile.getUpgradeLevel(type);
    final currentLevel = switch (stat) {
      'hp' => levels.hpLevel,
      'attack' => levels.attackLevel,
      'value' => levels.valueLevel,
      _ => 1,
    };
    return def.getUpgradeCost(currentLevel);
  }

  bool upgradeStat(PieceType type, String stat) {
    final cost = getUpgradeCost(type, stat);
    if (!profile.spendCoins(cost)) return false;

    final levels = profile.upgradeLevels[type] ?? UpgradeLevel(pieceType: type);

    switch (stat) {
      case 'hp':
        levels.hpLevel++;
      case 'attack':
        levels.attackLevel++;
      case 'value':
        levels.valueLevel++;
    }
    profile.upgradeLevels[type] = levels;
    notifyListeners();
    return true;
  }

  // ===== INIZIATIVA =====
  int get initiativeUpgradeCost => 300 * profile.initiative;

  bool upgradeInitiative() {
    if (!profile.spendCoins(initiativeUpgradeCost)) return false;
    profile.initiative++;
    notifyListeners();
    return true;
  }

  // ===== SKIN =====
  bool hasSkin(String skinId) => profile.ownedSkins.any((s) => s.skinId == skinId);

  bool buySkin(ShopSkinItem item) {
    if (hasSkin(item.skinId)) return false;
    if (!profile.spendCoins(item.cost)) return false;
    profile.ownedSkins.add(SkinOwnership(
      skinId: item.skinId,
      name: item.name,
      targetPiece: item.targetPiece,
    ));
    notifyListeners();
    return true;
  }

  void equipSkin(String skinId) {
    for (final skin in profile.ownedSkins) {
      skin.isEquipped = skin.skinId == skinId;
    }
    notifyListeners();
  }
}
