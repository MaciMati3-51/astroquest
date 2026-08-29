import 'package:flutter/material.dart';
import '../data/talisman_pool.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';

class TalismanRevealScreen extends StatelessWidget {
  const TalismanRevealScreen({super.key, required this.talisman});
  final TalismanDef talisman;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.cyberGold, size: 48),
              const SizedBox(height: 8),
              const Text(
                'Cosmic Aura Charged',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cyberGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                '運気浄化完了',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              GradientCard(
                colors: talisman.gradient,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Column(
                  children: [
                    Icon(talisman.icon, color: Colors.white, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      talisman.nameJa,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      talisman.name,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (talisman.isPro) ...[
                      const SizedBox(height: 12),
                      const Chip(
                        label: Text('Pro限定'),
                        backgroundColor: AppColors.cyberGold,
                        labelStyle: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
