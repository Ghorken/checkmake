// lib/models/player_profile.dart

import 'package:flutter/foundation.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';

class UpgradeLevel {
  final PieceType pieceType;
  int hpLevel;
  int attackLevel;
  int valueLevel;

  UpgradeLevel({
    required this.pieceType,
    this.hpLevel = 1,
    this.attackLevel = 1,
    this.valueLevel = 1,
  });

  Map<String, dynamic> toJson() => {
        'pieceType': pieceType.name,
        'hpLevel': hpLevel,
        'attackLevel': attackLevel,
        'valueLevel': valueLevel,
      };

  factory UpgradeLevel.fromJson(Map<String, dynamic> json) => UpgradeLevel(
        pieceType:
            PieceType.values.firstWhere((e) => e.name == json['pieceType']),
        hpLevel: json['hpLevel'],
        attackLevel: json['attackLevel'],
        valueLevel: json['valueLevel'],
      );
}

class SkinOwnership {
  final String skinId;
  final String name;
  final PieceType? targetPiece; // null = skin per tutti i pezzi (army skin)
  bool isEquipped;

  SkinOwnership({
    required this.skinId,
    required this.name,
    this.targetPiece,
    this.isEquipped = false,
  });

  Map<String, dynamic> toJson() => {
        'skinId': skinId,
        'name': name,
        'targetPiece': targetPiece?.name,
        'isEquipped': isEquipped,
      };

  factory SkinOwnership.fromJson(Map<String, dynamic> json) => SkinOwnership(
        skinId: json['skinId'] as String,
        name: json['name'] as String,
        targetPiece: json['targetPiece'] != null
            ? PieceType.values.firstWhere((e) => e.name == json['targetPiece'])
            : null,
        isEquipped: json['isEquipped'] as bool? ?? false,
      );
}

// Configurazione dell'esercito del giocatore
class ArmyConfig {
  // Mappa pieceType -> count (quanti ne metti nell'esercito)
  final Map<PieceType, int> composition;

  ArmyConfig({Map<PieceType, int>? composition})
      : composition = composition ?? _defaultComposition();

  static Map<PieceType, int> _defaultComposition() => {
        PieceType.pawn: 8,
        PieceType.rook: 2,
        PieceType.knight: 2,
        PieceType.bishop: 2,
        PieceType.queen: 1,
        PieceType.king: 1,
      };

  bool isValid() {
    // Verifica limiti per tipo base
    final countByBase = <PieceBaseType, int>{};
    for (final entry in composition.entries) {
      if (entry.value <= 0) continue;
      final def = pieceDefinitions[entry.key];
      if (def == null) continue;
      countByBase[def.baseType] =
          (countByBase[def.baseType] ?? 0) + entry.value;
    }
    for (final entry in countByBase.entries) {
      final max = pieceMaxCount[entry.key] ?? 0;
      if (entry.value > max) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'composition': composition.map((k, v) => MapEntry(k.name, v)),
      };

  factory ArmyConfig.fromJson(Map<String, dynamic> json) {
    final comp = (json['composition'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(
        PieceType.values.firstWhere((e) => e.name == k),
        v as int,
      ),
    );
    return ArmyConfig(composition: comp);
  }
}

class PlayerProfile extends ChangeNotifier {
  String name;
  int coins;
  int initiative; // livello di iniziativa
  Set<PieceType> unlockedPieces;
  Map<PieceType, UpgradeLevel> upgradeLevels;
  List<SkinOwnership> ownedSkins;
  ArmyConfig armyConfig;
  int wins;
  int losses;
  Set<String> unlockedAchievements;

  PlayerProfile({
    required this.name,
    this.coins = 500, // monete iniziali
    this.initiative = 1,
    Set<PieceType>? unlockedPieces,
    Map<PieceType, UpgradeLevel>? upgradeLevels,
    List<SkinOwnership>? ownedSkins,
    ArmyConfig? armyConfig,
    this.wins = 0,
    this.losses = 0,
    Set<String>? unlockedAchievements,
  })  : unlockedPieces = unlockedPieces ??
            {
              PieceType.pawn,
              PieceType.rook,
              PieceType.knight,
              PieceType.bishop,
              PieceType.queen,
              PieceType.king,
            },
        upgradeLevels = upgradeLevels ?? {},
        ownedSkins = ownedSkins ?? [],
        armyConfig = armyConfig ?? ArmyConfig(),
        unlockedAchievements = unlockedAchievements ?? {};

  /// Aggiorna la composizione dell'esercito e notifica tutti i listener (trigger salvataggio).
  void updateArmyConfig(ArmyConfig config) {
    armyConfig = config;
    notifyListeners();
  }

  /// Scala i coins e notifica tutti i listener (es. la home page).
  bool spendCoins(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    notifyListeners();
    return true;
  }

  /// Aggiunge coins e notifica tutti i listener.
  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }

  /// Registra una vittoria con eventuale ricompensa in coins.
  void registerWin({int coinsReward = 0}) {
    wins++;
    if (coinsReward > 0) {
      coins += coinsReward;
    }
    notifyListeners();
  }

  /// Registra una sconfitta con eventuale ricompensa in coins.
  void registerLoss({int coinsReward = 0}) {
    losses++;
    if (coinsReward > 0) {
      coins += coinsReward;
    }
    notifyListeners();
  }

  bool hasPiece(PieceType type) => unlockedPieces.contains(type);

  void unlockAchievement(String id, {SkinOwnership? skinReward}) {
    if (unlockedAchievements.contains(id)) return;
    unlockedAchievements.add(id);
    if (skinReward != null && !ownedSkins.any((s) => s.skinId == skinReward.skinId)) {
      ownedSkins.add(skinReward);
    }
    notifyListeners();
  }

  void equipSkin(String skinId) {
    for (final skin in ownedSkins) {
      skin.isEquipped = skin.skinId == skinId;
    }
    notifyListeners();
  }

  UpgradeLevel getUpgradeLevel(PieceType type) =>
      upgradeLevels[type] ?? UpgradeLevel(pieceType: type);

  Map<String, dynamic> toJson() => {
        'name': name,
        'coins': coins,
        'initiative': initiative,
        'army': armyConfig.toJson(),
        'upgrades': upgradeLevels.values.map((u) => u.toJson()).toList(),
        'wins': wins,
        'losses': losses,
        'unlockedPieces': unlockedPieces.map((e) => e.name).toList(),
        'ownedSkins': ownedSkins.map((s) => s.toJson()).toList(),
        'unlockedAchievements': unlockedAchievements.toList(),
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final upgrades = <PieceType, UpgradeLevel>{};
    for (final u in (json['upgrades'] as List)) {
      final upgrade = UpgradeLevel.fromJson(u as Map<String, dynamic>);
      upgrades[upgrade.pieceType] = upgrade;
    }
    final unlocked = json['unlockedPieces'] != null
        ? (json['unlockedPieces'] as List)
            .map((e) => PieceType.values.firstWhere((p) => p.name == e))
            .toSet()
        : null;
    final skins = json['ownedSkins'] != null
        ? (json['ownedSkins'] as List)
            .map((s) => SkinOwnership.fromJson(s as Map<String, dynamic>))
            .toList()
        : null;
    final achievements = json['unlockedAchievements'] != null
        ? (json['unlockedAchievements'] as List).cast<String>().toSet()
        : null;
    return PlayerProfile(
      name: json['name'] as String,
      coins: (json['coins'] as int?) ?? 500,
      initiative: (json['initiative'] as int?) ?? 1,
      armyConfig: ArmyConfig.fromJson(json['army'] as Map<String, dynamic>),
      upgradeLevels: upgrades,
      wins: (json['wins'] as int?) ?? 0,
      losses: (json['losses'] as int?) ?? 0,
      unlockedPieces: unlocked,
      ownedSkins: skins,
      unlockedAchievements: achievements,
    );
  }

  PieceStats getStatsForPiece(PieceType type) {
    final def = pieceDefinitions[type]!;
    final levels = getUpgradeLevel(type);
    return PieceStats(
      maxHp: def.getStatAtLevel(def.baseHp, def.hpScaleFactor, levels.hpLevel),
      currentHp:
          def.getStatAtLevel(def.baseHp, def.hpScaleFactor, levels.hpLevel),
      attack: def.getStatAtLevel(
          def.baseAttack, def.attackScaleFactor, levels.attackLevel),
      value: def.getStatAtLevel(
          def.baseValue, def.valueScaleFactor, levels.valueLevel),
    );
  }
}
