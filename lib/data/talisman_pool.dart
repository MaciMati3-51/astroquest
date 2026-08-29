import 'package:flutter/material.dart';

class TalismanDef {
  final String id;
  final String name;
  final String nameJa;
  final List<Color> gradient;
  final IconData icon;
  final bool isPro;

  const TalismanDef({
    required this.id,
    required this.name,
    required this.nameJa,
    required this.gradient,
    required this.icon,
    required this.isPro,
  });
}

const List<TalismanDef> talismanPool = [
  TalismanDef(
    id: 'ember_ward',
    name: 'Ember Ward',
    nameJa: '灯火の護符',
    gradient: [Color(0xFFFF5E3A), Color(0xFFFF2E63)],
    icon: Icons.local_fire_department,
    isPro: false,
  ),
  TalismanDef(
    id: 'stone_seal',
    name: 'Stone Seal',
    nameJa: '大地の封印',
    gradient: [Color(0xFF3E7C4A), Color(0xFFB08D57)],
    icon: Icons.terrain,
    isPro: false,
  ),
  TalismanDef(
    id: 'wind_sigil',
    name: 'Wind Sigil',
    nameJa: '風の紋章',
    gradient: [Color(0xFF6EE7E7), Color(0xFFB026FF)],
    icon: Icons.air,
    isPro: false,
  ),
  TalismanDef(
    id: 'tide_charm',
    name: 'Tide Charm',
    nameJa: '潮流のお守り',
    gradient: [Color(0xFF2E9CFF), Color(0xFF1B4FCC)],
    icon: Icons.water_drop,
    isPro: false,
  ),
  TalismanDef(
    id: 'nova_crest',
    name: 'Nova Crest',
    nameJa: '超新星の紋',
    gradient: [Color(0xFFF5C542), Color(0xFFFF2E63)],
    icon: Icons.auto_awesome,
    isPro: true,
  ),
  TalismanDef(
    id: 'void_relic',
    name: 'Void Relic',
    nameJa: '虚空の遺物',
    gradient: [Color(0xFFB026FF), Color(0xFF0A0E17)],
    icon: Icons.blur_circular,
    isPro: true,
  ),
  TalismanDef(
    id: 'starlight_key',
    name: 'Starlight Key',
    nameJa: '星光の鍵',
    gradient: [Color(0xFFF5C542), Color(0xFF6EE7E7)],
    icon: Icons.vpn_key,
    isPro: true,
  ),
  TalismanDef(
    id: 'aurora_veil',
    name: 'Aurora Veil',
    nameJa: 'オーロラの帳',
    gradient: [Color(0xFF6EE7E7), Color(0xFFB026FF)],
    icon: Icons.gradient,
    isPro: true,
  ),
];

List<TalismanDef> talismanPoolFor({required bool isPro}) {
  if (isPro) return talismanPool;
  return talismanPool.where((t) => !t.isPro).toList();
}

TalismanDef talismanById(String id) =>
    talismanPool.firstWhere((t) => t.id == id);
