// lib/screens/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/providers/shop_provider.dart';
import 'package:checkmake/widgets/piece_widget.dart';

const _gold = Color(0xFFD4AF37);
const _steelBlue = Color(0xFF2B5798);
const _crimson = Color(0xFF8B1E2D);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _ironBlack,
      appBar: AppBar(
        backgroundColor: _darkStone.withValues(alpha: 0.95),
        title: Row(
          children: [
            Text(l.shopTitle,
                style: GoogleFonts.cinzelDecorative(
                    color: _gold, fontSize: 18)),
            const Spacer(),
            const Icon(Icons.monetization_on, color: _gold, size: 18),
            const SizedBox(width: 4),
            Text(
              '${shop.profile.coins}',
              style: GoogleFonts.cormorantGaramond(
                  color: _gold, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _gold,
          indicatorWeight: 2,
          labelColor: _gold,
          unselectedLabelColor: _parchment.withValues(alpha: 0.5),
          labelStyle: GoogleFonts.cinzel(
              fontWeight: FontWeight.w700, fontSize: 12),
          tabs: [
            Tab(text: l.shopTabPieces),
            Tab(text: l.shopTabUpgrades),
            Tab(text: l.shopTabSkins),
          ],
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
        child: TabBarView(
          controller: _tabs,
          children: [
            _PiecesTab(shop: shop),
            _UpgradesTab(shop: shop),
            _SkinsTab(shop: shop),
          ],
        ),
      ),
    );
  }
}

// ===== TAB PEZZI =====
class _PiecesTab extends StatelessWidget {
  final ShopProvider shop;
  const _PiecesTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final unlockable =
        pieceDefinitions.values.where((d) => d.isUnlockable).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unlockable.length,
      itemBuilder: (context, i) {
        final def = unlockable[i];
        final owned = shop.profile.hasPiece(def.type);
        final canBuy = shop.canUnlock(def.type);

        return Card(
          color: _darkStone,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: _gold.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            leading: SizedBox(
              width: 48,
              height: 48,
              child: owned
                  ? PieceWidget(
                      piece: _dummyPiece(def.type, def.baseType),
                      size: 48,
                    )
                  : _LockedPieceIcon(baseType: def.baseType),
            ),
            title: Text(
              l.pieceNameFor(def.type),
              style: GoogleFonts.cinzel(
                  color: _parchment, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.pieceDescFor(def.type),
                    style: GoogleFonts.lora(
                        color: _parchment.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatChip('HP ${def.baseHp}', _crimson),
                    const SizedBox(width: 4),
                    _StatChip('ATK ${def.baseAttack}', _steelBlue),
                    const SizedBox(width: 4),
                    _StatChip('VAL ${def.baseValue}', _gold),
                  ],
                ),
                if (def.abilityFactory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _StatChip(
                        l.abilityNameFor(def.abilityFactory!()?.id ?? ''),
                        _gold),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: owned
                ? Icon(Icons.check_circle, color: _gold.withValues(alpha: 0.7))
                : ElevatedButton(
                    onPressed:
                        canBuy ? () => _buy(context, shop, def.type) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBuy ? _gold : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    child: Text(
                      '${def.unlockCost}',
                      style: GoogleFonts.cormorantGaramond(
                          color: _ironBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _buy(BuildContext context, ShopProvider shop, PieceType type) {
    final l = AppLocalizations.of(context)!;
    final success = shop.unlockPiece(type);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.shopUnlockSuccess(l.pieceNameFor(type))),
          backgroundColor: _steelBlue,
        ),
      );
    }
  }
}

// ===== TAB UPGRADES =====
class _UpgradesTab extends StatelessWidget {
  final ShopProvider shop;
  const _UpgradesTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final owned = shop.profile.unlockedPieces.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InitiativeCard(shop: shop),
        const SizedBox(height: 12),
        Text(l.shopUpgradePieces,
            style: GoogleFonts.cinzelDecorative(
                color: _gold, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ...owned.map((type) => _PieceUpgradeCard(shop: shop, type: type)),
      ],
    );
  }
}

class _InitiativeCard extends StatelessWidget {
  final ShopProvider shop;
  const _InitiativeCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Card(
      color: _darkStone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: _gold.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: _gold),
                const SizedBox(width: 8),
                Text(
                  l.shopInitiativeLabel(shop.profile.initiative),
                  style: GoogleFonts.cormorantGaramond(
                      color: _parchment, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l.shopInitiativeDesc,
              style: GoogleFonts.lora(
                color: _parchment.withValues(alpha: 0.65),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: shop.profile.coins >= shop.initiativeUpgradeCost
                  ? () => shop.upgradeInitiative()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
              ),
              child: Text(
                l.shopUpgradeBtn(shop.initiativeUpgradeCost),
                style: GoogleFonts.cormorantGaramond(
                    color: _ironBlack, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieceUpgradeCard extends StatelessWidget {
  final ShopProvider shop;
  final PieceType type;
  const _PieceUpgradeCard({required this.shop, required this.type});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final levels = shop.profile.getUpgradeLevel(type);

    return Card(
      color: _darkStone,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.pieceNameFor(type),
                style: GoogleFonts.cinzel(
                    color: _parchment, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _UpgradeRow(
              label: 'HP',
              icon: Icons.favorite,
              iconColor: _crimson,
              level: levels.hpLevel,
              cost: shop.getUpgradeCost(type, 'hp'),
              canAfford: shop.profile.coins >= shop.getUpgradeCost(type, 'hp'),
              onUpgrade: () => shop.upgradeStat(type, 'hp'),
            ),
            _UpgradeRow(
              label: 'ATK',
              icon: Icons.local_fire_department,
              iconColor: _steelBlue,
              level: levels.attackLevel,
              cost: shop.getUpgradeCost(type, 'attack'),
              canAfford:
                  shop.profile.coins >= shop.getUpgradeCost(type, 'attack'),
              onUpgrade: () => shop.upgradeStat(type, 'attack'),
            ),
            _UpgradeRow(
              label: l.shopStatValue,
              icon: Icons.monetization_on,
              iconColor: _gold,
              level: levels.valueLevel,
              cost: shop.getUpgradeCost(type, 'value'),
              canAfford:
                  shop.profile.coins >= shop.getUpgradeCost(type, 'value'),
              onUpgrade: () => shop.upgradeStat(type, 'value'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final int level;
  final int cost;
  final bool canAfford;
  final VoidCallback onUpgrade;

  const _UpgradeRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.level,
    required this.cost,
    required this.canAfford,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(
                    color: _parchment.withValues(alpha: 0.7), fontSize: 12)),
          ),
          Row(
            children: List.generate(
              level.clamp(0, 10),
              (_) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text('Lv.$level',
              style: GoogleFonts.cormorantGaramond(color: _gold, fontSize: 12)),
          const Spacer(),
          ElevatedButton(
            onPressed: canAfford ? onUpgrade : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              disabledBackgroundColor: Colors.grey.shade800,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
            ),
            child: Text(
              '+1 ($cost)',
              style: GoogleFonts.cormorantGaramond(
                color: _ironBlack,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== TAB SKIN =====
class _SkinsTab extends StatelessWidget {
  final ShopProvider shop;
  const _SkinsTab({required this.shop});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localizedSkins = _buildLocalizedSkins(l);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: localizedSkins.length,
      itemBuilder: (context, i) {
        final entry = localizedSkins[i];
        final skin = entry.item;
        final skinName = entry.name;
        final skinDesc = entry.description;
        final owned = shop.hasSkin(skin.skinId);
        final canBuy = !owned && shop.profile.coins >= skin.cost;

        return Card(
          color: _darkStone,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: _gold.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: skin.skinId.contains('fire')
                      ? [_gold, _crimson]
                      : skin.skinId.contains('ice')
                          ? [_parchment, _steelBlue]
                          : [_steelBlue, _ironBlack],
                ),
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              child: Icon(
                skin.targetPiece == null ? Icons.shield : Icons.person,
                color: _parchment,
              ),
            ),
            title: Text(skinName,
                style: GoogleFonts.cinzel(
                    color: _parchment, fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skinDesc,
                    style: GoogleFonts.lora(
                        color: _parchment.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontStyle: FontStyle.italic)),
                if (skin.targetPiece == null)
                  Text(l.shopSkinForArmy,
                      style: GoogleFonts.cinzel(
                          color: _gold, fontSize: 10)),
              ],
            ),
            trailing: owned
                ? TextButton(
                    onPressed: () => shop.equipSkin(skin.skinId),
                    child: Text(l.shopEquip,
                        style: GoogleFonts.cinzel(color: _steelBlue, fontSize: 11)),
                  )
                : ElevatedButton(
                    onPressed: canBuy ? () => shop.buySkin(skin) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBuy ? _gold : Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    child: Text('${skin.cost}',
                        style: GoogleFonts.cormorantGaramond(
                            color: _ironBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
          ),
        );
      },
    );
  }

  List<_LocalizedSkin> _buildLocalizedSkins(AppLocalizations l) {
    return [
      _LocalizedSkin(availableSkins[0], l.skinFireArmy, l.skinFireArmyDesc),
      _LocalizedSkin(availableSkins[1], l.skinIceArmy, l.skinIceArmyDesc),
      _LocalizedSkin(availableSkins[2], l.skinPawnShadow, l.skinPawnShadowDesc),
      _LocalizedSkin(
          availableSkins[3], l.skinQueenGolden, l.skinQueenGoldenDesc),
    ];
  }
}

class _LocalizedSkin {
  final ShopSkinItem item;
  final String name;
  final String description;
  const _LocalizedSkin(this.item, this.name, this.description);
}

// Helpers
class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(label,
            style: GoogleFonts.cinzel(
                color: _parchment, fontSize: 9, fontWeight: FontWeight.w600)),
      );
}

class _LockedPieceIcon extends StatelessWidget {
  final PieceBaseType baseType;
  const _LockedPieceIcon({required this.baseType});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _ironBlack,
          shape: BoxShape.circle,
          border: Border.all(color: _gold.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Icon(Icons.lock, color: _parchment.withValues(alpha: 0.5), size: 24),
        ),
      );
}

Piece _dummyPiece(PieceType type, PieceBaseType baseType) => Piece(
      id: 'shop_dummy_$type',
      type: type,
      baseType: baseType,
      side: PlayerSide.player1,
      stats: pieceDefinitions[type]!.createStats(),
    );
