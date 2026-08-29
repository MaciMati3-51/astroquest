import 'package:flutter/material.dart';

enum QuestCategory { deskStretch, hydration, grounding }

class QuestDef {
  final QuestCategory category;
  final String title;
  final String instruction;
  final int durationSeconds;
  final IconData icon;

  const QuestDef({
    required this.category,
    required this.title,
    required this.instruction,
    required this.durationSeconds,
    required this.icon,
  });
}

const List<QuestDef> questDefs = [
  QuestDef(
    category: QuestCategory.deskStretch,
    title: 'Desk Stretch',
    instruction: '座ったまま肩甲骨を大きく後ろに10回回す。',
    durationSeconds: 30,
    icon: Icons.accessibility_new,
  ),
  QuestDef(
    category: QuestCategory.hydration,
    title: 'Hydration',
    instruction: '立ち上がって水を一杯飲む。ポーション補充完了。',
    durationSeconds: 20,
    icon: Icons.local_drink,
  ),
  QuestDef(
    category: QuestCategory.grounding,
    title: 'Grounding',
    instruction: '目を閉じて深呼吸を3回。吸って4秒、吐いて4秒。',
    durationSeconds: 30,
    icon: Icons.self_improvement,
  ),
];

QuestDef questForSeed(int seed) => questDefs[seed % questDefs.length];
