import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../data/talisman_pool.dart';
import '../models/quest.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';
import 'talisman_reveal_screen.dart';

class QuestTimerScreen extends StatefulWidget {
  const QuestTimerScreen({
    super.key,
    required this.storage,
    required this.quest,
    required this.buffName,
  });

  final StorageService storage;
  final QuestDef quest;
  final String buffName;

  @override
  State<QuestTimerScreen> createState() => _QuestTimerScreenState();
}

class _QuestTimerScreenState extends State<QuestTimerScreen> {
  late int _remaining = widget.quest.durationSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        _complete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _complete() async {
    final pool = talismanPoolFor(isPro: widget.storage.isPro);
    final drawn = pool[Random().nextInt(pool.length)];
    await widget.storage.recordCompletion(drawn.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TalismanRevealScreen(talisman: drawn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;
    final total = quest.durationSeconds;
    final progress = 1 - (_remaining.clamp(0, total) / total);

    return Scaffold(
      appBar: AppBar(title: Text(quest.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientCard(
                colors: const [AppColors.neonPurple, AppColors.surfaceHigh],
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(quest.icon, color: Colors.white, size: 72),
                    const SizedBox(height: 24),
                    Text(
                      quest.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceHigh,
                        valueColor: const AlwaysStoppedAnimation(AppColors.cyberGold),
                      ),
                    ),
                    Text(
                      '$_remaining',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('獲得予定: ${widget.buffName}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
