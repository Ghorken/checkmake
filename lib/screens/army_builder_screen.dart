// lib/screens/army_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/models/player_profile.dart';
import 'package:checkmake/widgets/piece_widget.dart';

const _gold = Color(0xFFD4AF37);
const _steelBlue = Color(0xFF2B5798);
const _crimson = Color(0xFF8B1E2D);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);

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
    _profile.updateArmyConfig(ArmyConfig(composition: _draft));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.armySaved),
        backgroundColor: _steelBlue,
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
      backgroundColor: _ironBlack,
      appBar: AppBar(
        backgroundColor: _darkStone.withValues(alpha: 0.95),
        title: Text(l.armyBuilderTitle,
            style: GoogleFonts.cinzelDecorative(color: _gold, fontSize: 18)),
        actions: [
          TextButton.icon(
            onPressed: _isValid ? () => _save(context) : null,
            icon: const Icon(Icons.save, color: _gold),
            label: Text(l.armySave,
                style: GoogleFonts.cinzel(color: _gold, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _darkStone.withValues(alpha: 0.98),
                  const Color(0xFF0D1225),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: _gold.withValues(alpha: 0.35), width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: PieceBaseType.values.map((base) {
                final current = _countForBase(base);
                final max = pieceMaxCount[base] ?? 0;
                final isFull = current == max;
                return Column(
                  children: [
                    Text(
                      l.baseTypeLabel(base),
                      style: GoogleFonts.cinzel(
                          color: _parchment.withValues(alpha: 0.6),
                          fontSize: 9),
                    ),
                    Text(
                      '$current/$max',
                      style: GoogleFonts.cinzel(
                        color: isFull ? _gold : _parchment,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
                        style: GoogleFonts.cinzel(
                          color: _gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                    Divider(color: _gold.withValues(alpha: 0.2)),
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
      color: _darkStone,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: _gold.withValues(alpha: 0.12)),
      ),
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
                      style: GoogleFonts.cinzel(
                          color: _parchment,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(
                    'HP ${def.baseHp}  ATK ${def.baseAttack}',
                    style: GoogleFonts.lora(
                      color: _parchment.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: count > 0 ? onRemove : null,
                  icon: const Icon(Icons.remove_circle, color: _crimson),
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
                    style: GoogleFonts.cinzel(
                      color: _parchment,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: canAdd ? onAdd : null,
                  icon: Icon(Icons.add_circle,
                      color: canAdd ? _gold : Colors.grey.shade700),
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
