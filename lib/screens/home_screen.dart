import 'package:flutter/material.dart';
import '../data/content_pool.dart';
import '../models/cosmic_element.dart';
import '../models/quest.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';
import 'collection_screen.dart';
import 'paywall_screen.dart';
import 'quest_timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openQuest(QuestDef quest, String buffName) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestTimerScreen(
          storage: widget.storage,
          quest: quest,
          buffName: buffName,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openPaywall() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(storage: widget.storage, fromOnboarding: false),
      ),
    );
    if (mounted) setState(() {});
  }

  void _openCollection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionScreen(storage: widget.storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = widget.storage;
    final element = storage.element!;
    final today = DateTime.now();
    final seed = dailySeed(today);
    final quest = questForSeed(seed);
    final status = pickCosmicStatus(element, today);
    final buffName = pickBuffName(element, today);
    final completedToday = storage.completedToday;
    final isPro = storage.isPro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AstroQuest'),
        actions: [
          if (!isPro)
            TextButton.icon(
              onPressed: _openPaywall,
              icon: const Icon(Icons.workspace_premium, color: AppColors.cyberGold, size: 18),
              label: const Text('Go Pro', style: TextStyle(color: AppColors.cyberGold)),
            ),
          IconButton(
            onPressed: _openCollection,
            icon: const Icon(Icons.collections_bookmark),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GradientCard(
              colors: element.gradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(element.icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Cosmic Status',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _StreakCard(streak: storage.streakCount, isPro: isPro),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buff Mission',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(quest.icon, color: AppColors.cyberGold),
                      const SizedBox(width: 8),
                      Text(quest.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(quest.instruction, style: const TextStyle(color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('達成報酬: $buffName バフ',
                      style: const TextStyle(color: AppColors.cyberGold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: completedToday ? null : () => _openQuest(quest, buffName),
                      child: Text(completedToday ? '本日のミッション達成済み' : 'クエスト開始（${quest.durationSeconds}秒）'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.isPro});
  final int streak;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.cyberGold, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak日連続',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  isPro ? '全履歴を記録中' : 'Free: 直近7日間のみ記録',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
