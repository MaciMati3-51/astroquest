import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// RevenueCat課金フローのローカルスタブ。
/// 本物のストア決済は接続していない。タップでisProフラグをONにするのみ。
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    super.key,
    required this.storage,
    required this.fromOnboarding,
  });

  final StorageService storage;
  final bool fromOnboarding;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _purchasing = false;
  bool _annual = true;

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(storage: widget.storage)),
      (route) => false,
    );
  }

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    await Future.delayed(const Duration(milliseconds: 900)); // 決済処理を模擬
    await widget.storage.setIsPro(true);
    if (!mounted) return;
    setState(() => _purchasing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pro購入完了（サンドボックス）')),
    );
    _goHome();
  }

  void _skip() {
    if (widget.fromOnboarding) {
      _goHome();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _purchasing ? null : _skip,
                  child: Text(
                    widget.fromOnboarding ? 'Freeで始める' : '閉じる',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.auto_awesome, color: AppColors.cyberGold, size: 48),
              const SizedBox(height: 16),
              Text(
                'AstroQuest Pro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'あなたの属性に合わせた限定タリスマンと、Streak全履歴を解放する。',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              const _FeatureRow(text: '限定タリスマンカード（4種）'),
              const _FeatureRow(text: 'Streak全履歴の閲覧'),
              const _FeatureRow(text: 'Freeの全機能'),
              const SizedBox(height: 24),
              _PlanTile(
                title: 'Annual',
                price: '\$29.99 / 年',
                subtitle: '\$2.50/月換算・7日間無料体験',
                selected: _annual,
                onTap: () => setState(() => _annual = true),
              ),
              const SizedBox(height: 12),
              _PlanTile(
                title: 'Monthly',
                price: '\$4.99 / 月',
                subtitle: '7日間無料体験',
                selected: !_annual,
                onTap: () => setState(() => _annual = false),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _purchasing ? null : _purchase,
                child: _purchasing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('無料体験を始める'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.neonPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.neonPurple : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text(price, style: const TextStyle(color: AppColors.cyberGold, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
