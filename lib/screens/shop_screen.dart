// lib/screens/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/l10n/piece_strings.dart';
import 'package:checkmake/models/piece.dart';
import 'package:checkmake/models/piece_definitions.dart';
import 'package:checkmake/providers/shop_provider.dart';
import 'package:checkmake/widgets/piece_widget.dart';

const _gold = Color(0xFFFFD700);
const _blue = Color(0xFF1A468E);
const _red = Color(0xFFB22222);
const _black = Color(0xFFFDF5E6);
const _white = Color(0xFFFDF5E6);

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
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: Row(
          children: [
            Text(l.shopTitle, style: const TextStyle(color: _gold)),
            const Spacer(),
            const Icon(Icons.monetization_on, color: _gold, size: 18),
            const SizedBox(width: 4),
            Text(
              '${shop.profile.coins}',
              style: const TextStyle(color: _gold, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _gold,
          labelColor: _gold,
          unselectedLabelColor: _white,
          tabs: [
            Tab(text: l.shopTabPieces),
            Tab(text: l.shopTabUpgrades),
            Tab(text: l.shopTabSkins),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PiecesTab(shop: shop),
          _UpgradesTab(shop: shop),
          _SkinsTab(shop: shop),
        ],
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
          color: const Color(0xFF2C3E50),
          margin: const EdgeInsets.only(bottom: 10),
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
              style:
                  const TextStyle(color: _white, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.pieceDescFor(def.type),
                    style: const TextStyle(color: _white, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatChip('❤️ ${def.baseHp}'),
                    const SizedBox(width: 4),
                    _StatChip('⚔️ ${def.baseAttack}'),
                    const SizedBox(width: 4),
                    _StatChip('🪙 ${def.baseValue}'),
                  ],
                ),
                if (def.abilityFactory != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _StatChip(
                        '✨ ${l.abilityNameFor(def.abilityFactory!()?.id ?? '')}'),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: owned
                ? const Icon(Icons.check_circle, color: _gold)
                : ElevatedButton(
                    onPressed:
                        canBuy ? () => _buy(context, shop, def.type) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBuy ? _gold : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    child: Text(
                      '${def.unlockCost}🪙',
                      style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 12),
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
          backgroundColor: _blue,
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
            style: const TextStyle(
                color: _gold, fontWeight: FontWeight.bold, fontSize: 16)),
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
      color: const Color(0xFF2C3E50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: _gold),
                const SizedBox(width: 8),
                Text(
                  l.shopInitiativeLabel(shop.profile.initiative),
                  style: const TextStyle(
                      color: _white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l.shopInitiativeDesc,
              style: const TextStyle(color: _white, fontSize: 11),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: shop.profile.coins >= shop.initiativeUpgradeCost
                  ? () => shop.upgradeInitiative()
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: _gold),
              child: Text(
                l.shopUpgradeBtn(shop.initiativeUpgradeCost),
                style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 12),
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
      color: const Color(0xFF2C3E50),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.pieceNameFor(type),
                style: const TextStyle(
                    color: _white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _UpgradeRow(
              label: '❤️ HP',
              level: levels.hpLevel,
              cost: shop.getUpgradeCost(type, 'hp'),
              canAfford: shop.profile.coins >= shop.getUpgradeCost(type, 'hp'),
              onUpgrade: () => shop.upgradeStat(type, 'hp'),
            ),
            _UpgradeRow(
              label: '⚔️ ATK',
              level: levels.attackLevel,
              cost: shop.getUpgradeCost(type, 'attack'),
              canAfford:
                  shop.profile.coins >= shop.getUpgradeCost(type, 'attack'),
              onUpgrade: () => shop.upgradeStat(type, 'attack'),
            ),
            _UpgradeRow(
              label: l.shopStatValue,
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
  final int level;
  final int cost;
  final bool canAfford;
  final VoidCallback onUpgrade;

  const _UpgradeRow({
    required this.label,
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
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: Color(0xCCFDF5E6), fontSize: 12)),
          ),
          Row(
            children: List.generate(
              level.clamp(0, 10),
              (_) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 2),
                decoration: const BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Text('Lv.$level', style: const TextStyle(color: _gold, fontSize: 10)),
          const Spacer(),
          ElevatedButton(
            onPressed: canAfford ? onUpgrade : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(0, 30),
            ),
            child: Text(
              '+1 ($cost🪙)',
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 11,
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

    // Skin con nomi e descrizioni localizzate
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
          color: const Color(0xFF2C3E50),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: skin.skinId.contains('fire')
                      ? [_gold, _red]
                      : skin.skinId.contains('ice')
                          ? [_white, _blue]
                          : [_blue, _black],
                ),
              ),
              child: Icon(
                skin.targetPiece == null ? Icons.shield : Icons.person,
                color: Color(0xFFFDF5E6),
              ),
            ),
            title: Text(skinName, style: const TextStyle(color: Color(0xFFFDF5E6))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skinDesc,
                    style: const TextStyle(color: _white, fontSize: 11)),
                if (skin.targetPiece == null)
                  Text(l.shopSkinForArmy,
                      style: const TextStyle(color: _gold, fontSize: 10)),
              ],
            ),
            trailing: owned
                ? TextButton(
                    onPressed: () => shop.equipSkin(skin.skinId),
                    child:
                        Text(l.shopEquip, style: const TextStyle(color: _blue)),
                  )
                : ElevatedButton(
                    onPressed: canBuy ? () => shop.buySkin(skin) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canBuy ? _gold : Colors.grey,
                    ),
                    child: Text('${skin.cost}🪙',
                        style:
                            const TextStyle(color: Color(0xFF2C3E50), fontSize: 12)),
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
  const _StatChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.2),
          border: Border.all(color: _gold.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(color: _white, fontSize: 10)),
      );
}

class _LockedPieceIcon extends StatelessWidget {
  final PieceBaseType baseType;
  const _LockedPieceIcon({required this.baseType});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _black,
          shape: BoxShape.circle,
          border: Border.all(color: _gold.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Icon(Icons.lock, color: _white, size: 24),
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
