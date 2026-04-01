import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:checkmake/l10n/app_localizations.dart';
import 'package:checkmake/providers/shop_provider.dart';

const _gold = Color(0xFFD4AF37);
const _steelBlue = Color(0xFF2B5798);
const _crimson = Color(0xFF8B1E2D);
const _ironBlack = Color(0xFF0A0A0F);
const _parchment = Color(0xFFF0E6D3);
const _darkStone = Color(0xFF1A1A2E);

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final l = AppLocalizations.of(context)!;
    final localizedSkins = _buildLocalizedSkins(l);

    return Scaffold(
      backgroundColor: _ironBlack,
      appBar: AppBar(
        backgroundColor: _darkStone.withValues(alpha: 0.95),
        title: Row(
          children: [
            Text(
              l.shopTabSkins,
              style: GoogleFonts.cinzelDecorative(color: _gold, fontSize: 18),
            ),
            const Spacer(),
            const Icon(Icons.monetization_on, color: _gold, size: 18),
            const SizedBox(width: 4),
            Text(
              '${shop.profile.coins}',
              style: GoogleFonts.cinzel(
                  color: _gold, fontWeight: FontWeight.bold),
            ),
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
        child: ListView.builder(
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
                        color: _parchment,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
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
                          style:
                              GoogleFonts.cinzel(color: _gold, fontSize: 10)),
                  ],
                ),
                trailing: owned
                    ? TextButton(
                        onPressed: () => shop.equipSkin(skin.skinId),
                        child: Text(l.shopEquip,
                            style: GoogleFonts.cinzel(
                                color: _steelBlue, fontSize: 11)),
                      )
                    : ElevatedButton(
                        onPressed: canBuy ? () => shop.buySkin(skin) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canBuy ? _gold : Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        child: Text('${skin.cost}',
                            style: GoogleFonts.cinzel(
                                color: _ironBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<_LocalizedSkin> _buildLocalizedSkins(AppLocalizations l) => [];
}

class _LocalizedSkin {
  final ShopSkinItem item;
  final String name;
  final String description;
  const _LocalizedSkin(this.item, this.name, this.description);
}
