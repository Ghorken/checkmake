// lib/screens/army_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/widgets/piece_widget.dart';

const _gold = Color(0xFFD4AF37);
const _blue = Color(0xFF1E3A8A);
const _red = Color(0xFF8B1E2D);
const _black = Color(0xFF0B0B10);
const _white = Color(0xFFF8F7F2);

class ArmyBuilderScreen extends StatefulWidget {
  const ArmyBuilderScreen({super.key});

  @override
  State<ArmyBuilderScreen> createState() => _ArmyBuilderScreenState();
}

class _ArmyBuilderScreenState extends State<ArmyBuilderScreen> {
  late Map<PieceType, int> _draft;
  late PlayerProfile _profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profile = context.read<PlayerProfile>();
    _draft = Map.from(_profile.armyConfig.composition);
  }

  int _countForBase(PieceBaseType base) {
    int total = 0;
    _draft.forEach((type, count) {
      final def = pieceDefinitions[type];
      if (def != null && def.baseType == base) total += count;
    });
    return total;
  }

  bool _canAdd(PieceType type) {
    final def = pieceDefinitions[type]!;
    final max = pieceMaxCount[def.baseType] ?? 0;
    return _countForBase(def.baseType) < max;
  }

  void _add(PieceType type) {
    if (!_canAdd(type)) return;
    setState(() {
      _draft[type] = (_draft[type] ?? 0) + 1;
    });
  }

  void _remove(PieceType type) {
    setState(() {
      final cur = _draft[type] ?? 0;
      if (cur <= 0) return;
      if (cur == 1) {
        _draft.remove(type);
      } else {
        _draft[type] = cur - 1;
      }
    });
  }

  bool get _isValid => ArmyConfig(composition: _draft).isValid();

  void _save(BuildContext context) {
    if (!_isValid) return;
    final l = AppLocalizations.of(context)!;
    _profile.armyConfig = ArmyConfig(composition: _draft);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.armySaved),
        backgroundColor: _blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final groups = <PieceBaseType, List<PieceDefinition>>{};
    for (final def in pieceDefinitions.values) {
      if (_profile.hasPiece(def.type)) {
        groups.putIfAbsent(def.baseType, () => []).add(def);
      }
    }

    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111626),
        title: Text(l.armyBuilderTitle, style: const TextStyle(color: _gold)),
        actions: [
          TextButton.icon(
            onPressed: _isValid ? () => _save(context) : null,
            icon: const Icon(Icons.save, color: _gold),
            label: Text(l.armySave, style: const TextStyle(color: _gold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF111626),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: PieceBaseType.values.map((base) {
                final current = _countForBase(base);
                final max = pieceMaxCount[base] ?? 0;
                return Column(
                  children: [
                    Text(
                      l.baseTypeLabel(base),
                      style: const TextStyle(color: _white, fontSize: 10),
                    ),
                    Text(
                      '$current/$max',
                      style: TextStyle(
                        color: current == max ? _gold : _white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: PieceBaseType.values.map((base) {
                final pieces = groups[base] ?? [];
                if (pieces.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '${l.baseTypeLabel(base)} (${_countForBase(base)}/${pieceMaxCount[base]})',
                        style: const TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ...pieces.map((def) => _PieceRow(
                          def: def,
                          count: _draft[def.type] ?? 0,
                          canAdd: _canAdd(def.type),
                          onAdd: () => _add(def.type),
                          onRemove: () => _remove(def.type),
                        )),
                    const Divider(color: _gold),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceRow extends StatelessWidget {
  final PieceDefinition def;
  final int count;
  final bool canAdd;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _PieceRow({
    required this.def,
    required this.count,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Card(
      color: const Color(0xFF111626),
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: PieceWidget(
                piece: Piece(
                  id: 'builder_${def.type}',
                  type: def.type,
                  baseType: def.baseType,
                  side: PlayerSide.player1,
                  stats: def.createStats(),
                ),
                size: 40,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.pieceNameFor(def.type),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    '❤️${def.baseHp} ⚔️${def.baseAttack} 🪙${def.baseValue}',
                    style: const TextStyle(color: _white, fontSize: 10),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: count > 0 ? onRemove : null,
                  icon: const Icon(Icons.remove_circle, color: _red),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                SizedBox(
                  width: 24,
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: canAdd ? onAdd : null,
                  icon: Icon(Icons.add_circle,
                      color: canAdd ? _gold : Colors.grey),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
