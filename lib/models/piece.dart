// lib/models/piece.dart

enum PassiveEffect {
  doubleAttack,
}

enum ActiveEffect {
  heal,
  piercingShot,
}

enum PieceType {
  // Pezzi standard
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
  // Pezzi sbloccabili
  fighter,
  balista,
}

enum PieceBaseType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}

enum PlayerSide { player1, player2 }

class PieceStats {
  final int maxHp;
  int currentHp;
  final int attack;
  final int value; // valore in monete quando viene eliminato
  int hpLevel;
  int attackLevel;

  PieceStats({
    required this.maxHp,
    required this.currentHp,
    required this.attack,
    required this.value,
    this.hpLevel = 1,
    this.attackLevel = 1,
  });

  bool get isHalfHp => currentHp <= maxHp / 2;
  bool get isDead => currentHp <= 0;

  PieceStats copyWith({
    int? maxHp,
    int? currentHp,
    int? attack,
    int? value,
    int? hpLevel,
    int? attackLevel,
  }) {
    return PieceStats(
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attack: attack ?? this.attack,
      value: value ?? this.value,
      hpLevel: hpLevel ?? this.hpLevel,
      attackLevel: attackLevel ?? this.attackLevel,
    );
  }
}

class SpecialAbility {
  final String id;
  final String name;
  final String description;
  final bool isPassive;
  final int cooldown; // turni di cooldown (ignorato se isPassive)
  int currentCooldown;

  // Effetto passivo (sempre attivo)
  final PassiveEffect? passiveEffect;
  final double passiveValue; // valore frazionario, es. 0.20 = 20%

  // Effetto attivo (si usa cliccando il tasto abilità)
  final ActiveEffect? activeEffect;
  final double activeValue; // valore frazionario, es. 0.30 = 30%

  SpecialAbility({
    required this.id,
    required this.name,
    required this.description,
    this.isPassive = false,
    this.cooldown = 0,
    this.currentCooldown = 0,
    this.passiveEffect,
    this.passiveValue = 0.0,
    this.activeEffect,
    this.activeValue = 0.0,
  });

  bool get isReady => !isPassive && currentCooldown == 0;
}

class Piece {
  final String id; // ID univoco istanza
  final PieceType type;
  final PieceBaseType baseType;
  final PlayerSide side;
  PieceStats stats;
  final SpecialAbility? specialAbility;
  String? equippedSkin; // ID della skin equipaggiata
  bool hasMoved; // per castling e mosse speciali
  ActiveEffect? activeBuff; // buff temporaneo da abilità attiva, azzerato dopo il combattimento

  Piece({
    required this.id,
    required this.type,
    required this.baseType,
    required this.side,
    required this.stats,
    this.specialAbility,
    this.equippedSkin,
    this.hasMoved = false,
    this.activeBuff,
  });

  // Immagine da mostrare in base alla vita
  String get imagePath {
    final skinPrefix = equippedSkin != null ? 'skins/${equippedSkin}_' : 'pieces/';
    final perspective = side == PlayerSide.player1 ? 'back' : 'front';
    final state = stats.isHalfHp ? 'half' : 'full';
    return 'assets/images/$skinPrefix${type.name}_${perspective}_$state.png';
  }

  Piece copyWith({
    PieceStats? stats,
    String? equippedSkin,
    bool? hasMoved,
  }) {
    return Piece(
      id: id,
      type: type,
      baseType: baseType,
      side: side,
      stats: stats ?? this.stats,
      specialAbility: specialAbility,
      equippedSkin: equippedSkin ?? this.equippedSkin,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
