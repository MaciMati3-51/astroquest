import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/talisman_pool.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'paywall_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    final unlocked = storage.unlockedTalismanIds.toSet();
    final isPro = storage.isPro;
    final allDates = List.of(storage.completionDates)..sort((a, b) => b.compareTo(a));
    final visibleDates = isPro ? allDates : allDates.take(7).toList();
    final hiddenCount = allDates.length - visibleDates.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Talismans',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: talismanPool.map((t) {
                final owned = unlocked.contains(t.id);
                final proLocked = t.isPro && !isPro;
                return _TalismanTile(talisman: t, owned: owned, proLocked: proLocked);
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text('Streak History',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (visibleDates.isEmpty)
              const Text('まだ記録がない。今日のミッションを達成しよう。',
                  style: TextStyle(color: AppColors.textSecondary))
            else
              ...visibleDates.map((d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text(DateFormat('yyyy/MM/dd (E)', 'ja').format(d),
                            style: const TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  )),
            if (!isPro && hiddenCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('さらに$hiddenCount件の履歴はProで解放',
                          style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaywallScreen(storage: storage, fromOnboarding: false),
                        ),
                      ),
                      child: const Text('Go Pro'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TalismanTile extends StatelessWidget {
  const _TalismanTile({required this.talisman, required this.owned, required this.proLocked});
  final TalismanDef talisman;
  final bool owned;
  final bool proLocked;

  @override
  Widget build(BuildContext context) {
    final dimmed = !owned;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dimmed
              ? [AppColors.surfaceHigh, AppColors.surface]
              : talisman.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            proLocked ? Icons.lock : talisman.icon,
            color: dimmed ? AppColors.textSecondary : Colors.white,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            owned ? talisman.nameJa : (proLocked ? 'Pro限定' : '未獲得'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dimmed ? AppColors.textSecondary : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
