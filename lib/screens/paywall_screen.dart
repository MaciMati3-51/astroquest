import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/purchase_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Pro購入画面。
///
/// RevenueCatが構成済み（APIキーあり・Offering取得成功）なら実際の商品を表示し、
/// `Purchases.purchase` でGoogle Playの決済フローを起動する。
/// 未構成なら固定表示のスタブプランにフォールバックする。
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
  final PurchaseService _purchases = PurchaseService.instance;

  bool _loading = true;
  bool _busy = false;
  Offering? _offering;
  Package? _selected;

  /// スタブ表示時にAnnualを選んでいるか。
  bool _stubAnnual = true;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    final offering = await _purchases.fetchCurrentOffering();
    if (!mounted) return;
    setState(() {
      _offering = offering;
      // 年額があれば初期選択にする。無ければ先頭。
      final packages = offering?.availablePackages ?? const <Package>[];
      if (packages.isNotEmpty) {
        _selected = packages.firstWhere(
          (p) => p.packageType == PackageType.annual,
          orElse: () => packages.first,
        );
      }
      _loading = false;
    });
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomeScreen(storage: widget.storage)),
      (route) => false,
    );
  }

  Future<void> _runPurchaseFlow(Future<PurchaseOutcome> Function() action) async {
    setState(() => _busy = true);
    final outcome = await action();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (outcome) {
      case PurchaseOutcome.success:
        _showMessage(_purchases.isLive ? 'Proが有効になった' : 'Pro購入完了（スタブ）');
        _goHome();
      case PurchaseOutcome.cancelled:
        // ユーザーが自分で閉じた場合は何も出さない。
        break;
      case PurchaseOutcome.failed:
        _showMessage('購入を完了できなかった。時間をおいて試すこと。');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  /// 選択中のパッケージを購入する。
  /// _selected がnullなのはRevenueCat未構成のスタブ表示時だけで、
  /// その場合はPurchaseService側がスタブ経路に落とす。
  Future<void> _buy() => _runPurchaseFlow(() => _purchases.purchase(_selected));

  Future<void> _restore() => _runPurchaseFlow(_purchases.restore);

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
                  onPressed: _busy ? null : _skip,
                  child: Text(
                    widget.fromOnboarding ? 'Freeで始める' : '閉じる',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.auto_awesome,
                  color: AppColors.cyberGold, size: 48),
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
              Expanded(child: _buildPlans()),
              ElevatedButton(
                onPressed: _busy || _loading ? null : _buy,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('無料体験を始める'),
              ),
              TextButton(
                onPressed: _busy ? null : _restore,
                child: const Text(
                  '購入を復元',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlans() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonPurple),
      );
    }

    final packages = _offering?.availablePackages;
    if (packages == null || packages.isEmpty) {
      // RevenueCat未構成 or 商品未設定。表示だけの固定プランに落とす。
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          _PlanTile(
            title: 'Annual',
            price: '\$29.99 / 年',
            subtitle: '\$2.50/月換算・7日間無料体験',
            selected: _stubAnnual,
            onTap: () => setState(() => _stubAnnual = true),
          ),
          const SizedBox(height: 12),
          _PlanTile(
            title: 'Monthly',
            price: '\$4.99 / 月',
            subtitle: '7日間無料体験',
            selected: !_stubAnnual,
            onTap: () => setState(() => _stubAnnual = false),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: packages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final package = packages[i];
        return _PlanTile(
          title: _planTitle(package.packageType),
          price: package.storeProduct.priceString,
          subtitle: _planSubtitle(package),
          selected: _selected?.identifier == package.identifier,
          onTap: () => setState(() => _selected = package),
        );
      },
    );
  }

  String _planTitle(PackageType type) => switch (type) {
        PackageType.annual => 'Annual',
        PackageType.sixMonth => '6ヶ月',
        PackageType.threeMonth => '3ヶ月',
        PackageType.twoMonth => '2ヶ月',
        PackageType.monthly => 'Monthly',
        PackageType.weekly => 'Weekly',
        PackageType.lifetime => '買い切り',
        _ => 'プラン',
      };

  /// 無料体験・月額換算などの補足行。取れた情報だけを出す。
  String _planSubtitle(Package package) {
    final product = package.storeProduct;
    final parts = <String>[];

    final intro = product.introductoryPrice;
    if (intro != null && intro.price == 0) {
      parts.add('${intro.periodNumberOfUnits}${_unitLabel(intro.periodUnit)}無料体験');
    } else if (intro != null) {
      parts.add('初回 ${intro.priceString}');
    }

    if (package.packageType == PackageType.annual &&
        product.pricePerMonthString != null) {
      parts.add('${product.pricePerMonthString}/月換算');
    }

    return parts.isEmpty ? product.description : parts.join('・');
  }

  String _unitLabel(PeriodUnit unit) => switch (unit) {
        PeriodUnit.day => '日間',
        PeriodUnit.week => '週間',
        PeriodUnit.month => 'ヶ月',
        PeriodUnit.year => '年',
        PeriodUnit.unknown => '',
      };
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
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(
                    color: AppColors.cyberGold, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
