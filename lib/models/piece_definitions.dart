// lib/models/piece_definitions.dart
// Configurazione di tutti i pezzi del gioco

import 'package:checkmake/models/piece.dart';

class PieceDefinition {
  final PieceType type;
  final PieceBaseType baseType;
  final String displayName;
  final String description;
  final int baseHp;
  final int baseAttack;
  final int baseValue;
  final bool isUnlockable;
  final int unlockCost;
  // Fattori di scaling per upgrades (moltiplicatori per livello)
  final double hpScaleFactor;
  final double attackScaleFactor;
  final double valueScaleFactor;
  final int upgradeCostBase;
  final SpecialAbility? Function()? abilityFactory;

  const PieceDefinition({
    required this.type,
    required this.baseType,
    required this.displayName,
    required this.description,
    required this.baseHp,
    required this.baseAttack,
    required this.baseValue,
    required this.isUnlockable,
    this.unlockCost = 0,
    this.hpScaleFactor = 1.3,
    this.attackScaleFactor = 1.25,
    this.valueScaleFactor = 1.2,
    this.upgradeCostBase = 100,
    this.abilityFactory,
  });

  PieceStats createStats() => PieceStats(
        maxHp: baseHp,
        currentHp: baseHp,
        attack: baseAttack,
        value: baseValue,
      );

  int getUpgradeCost(int currentLevel) => (upgradeCostBase * (currentLevel * 1.5)).toInt();

  int getStatAtLevel(int base, double scaleFactor, int level) => (base * (1 + scaleFactor * (level - 1))).toInt();
}

// =========================================
//  REGISTRO GLOBALE DEI PEZZI
// =========================================
final Map<PieceType, PieceDefinition> pieceDefinitions = {
  // --- PEZZI BASE ---
  PieceType.pawn: PieceDefinition(
    type: PieceType.pawn,
    baseType: PieceBaseType.pawn,
    displayName: 'Pedone',
    description: 'Il soldato base, muove avanti e cattura in diagonale.',
    baseHp: 30,
    baseAttack: 10,
    baseValue: 5,
    isUnlockable: false,
    upgradeCostBase: 50,
  ),
  PieceType.rook: PieceDefinition(
    type: PieceType.rook,
    baseType: PieceBaseType.rook,
    displayName: 'Torre',
    description: 'Muove in linea retta, alta resistenza.',
    baseHp: 80,
    baseAttack: 25,
    baseValue: 20,
    isUnlockable: false,
    upgradeCostBase: 120,
  ),
  PieceType.knight: PieceDefinition(
    type: PieceType.knight,
    baseType: PieceBaseType.knight,
    displayName: 'Cavallo',
    description: 'Muove a L, può scavalcare i pezzi.',
    baseHp: 50,
    baseAttack: 20,
    baseValue: 15,
    isUnlockable: false,
    upgradeCostBase: 100,
  ),
  PieceType.bishop: PieceDefinition(
    type: PieceType.bishop,
    baseType: PieceBaseType.bishop,
    displayName: 'Alfiere',
    description: 'Muove in diagonale, velocità elevata.',
    baseHp: 45,
    baseAttack: 18,
    baseValue: 12,
    isUnlockable: false,
    upgradeCostBase: 100,
  ),
  PieceType.queen: PieceDefinition(
    type: PieceType.queen,
    baseType: PieceBaseType.queen,
    displayName: 'Regina',
    description: 'Il pezzo più potente, muove in tutte le direzioni.',
    baseHp: 100,
    baseAttack: 40,
    baseValue: 50,
    isUnlockable: false,
    upgradeCostBase: 200,
  ),
  PieceType.king: PieceDefinition(
    type: PieceType.king,
    baseType: PieceBaseType.king,
    displayName: 'Re',
    description: 'Va protetto. La sua caduta significa sconfitta.',
    baseHp: 120,
    baseAttack: 15,
    baseValue: 0, // non genera monete, fine partita
    isUnlockable: false,
    upgradeCostBase: 300,
  ),

  // --- PEZZI SBLOCCABILI ---
  PieceType.fighter: PieceDefinition(
    type: PieceType.fighter,
    baseType: PieceBaseType.pawn,
    displayName: 'Combattente',
    description:
        'Muove come un pedone. Se sopravvive allo scontro, attacca una seconda volta senza ricevere danno.',
    baseHp: 30,
    baseAttack: 10,
    baseValue: 5,
    isUnlockable: true,
    unlockCost: 200,
    upgradeCostBase: 75,
    abilityFactory: () => SpecialAbility(
      id: 'double_attack',
      name: 'Doppio Attacco',
      description:
          'Se sopravvive allo scontro, attacca una seconda volta senza ricevere danno.',
      isPassive: true,
      passiveEffect: PassiveEffect.doubleAttack,
    ),
  ),
  PieceType.balista: PieceDefinition(
    type: PieceType.balista,
    baseType: PieceBaseType.rook,
    displayName: 'Ballista',
    description:
        'Muove e attacca come una torre. Abilita attiva: scaglia una freccia su un nemico in linea retta, ignorando i pezzi intermedi.',
    baseHp: 70,
    baseAttack: 28,
    baseValue: 28,
    isUnlockable: true,
    unlockCost: 420,
    upgradeCostBase: 140,
    abilityFactory: () => SpecialAbility(
      id: 'piercing_shot',
      name: 'Freccia Perforante',
      description:
          'Colpisce un nemico sulla stessa riga o colonna ignorando i pezzi intermedi.',
      cooldown: 2,
      activeEffect: ActiveEffect.piercingShot,
      activeValue: 1.0,
    ),
  ),

};

// Limiti per tipo base (come negli scacchi standard)
const Map<PieceBaseType, int> pieceMaxCount = {
  PieceBaseType.pawn: 8,
  PieceBaseType.rook: 2,
  PieceBaseType.knight: 2,
  PieceBaseType.bishop: 2,
  PieceBaseType.queen: 1,
  PieceBaseType.king: 1,
};
