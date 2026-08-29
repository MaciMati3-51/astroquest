import 'package:flutter/material.dart';
import '../models/cosmic_element.dart';
import '../models/zodiac.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';
import 'paywall_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DateTime? _birthDate;
  SunSign? _revealedSign;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.neonPurple,
                surface: AppColors.surface,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _reveal() async {
    final date = _birthDate;
    if (date == null) return;
    final sign = sunSignFromBirthDate(date);
    await widget.storage.setBirthDate(date);
    await widget.storage.setElement(sign.element);
    setState(() => _revealedSign = sign);
  }

  Future<void> _finish() async {
    await widget.storage.setOnboardingDone(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(storage: widget.storage, fromOnboarding: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sign = _revealedSign;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: sign == null ? _buildDateStep() : _buildRevealStep(sign),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.auto_awesome, color: AppColors.cyberGold, size: 56),
        const SizedBox(height: 16),
        Text(
          'AstroQuest',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '生年月日から、あなたのエレメントを診断する。',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
        OutlinedButton(
          onPressed: _pickDate,
          child: Text(_birthDate == null
              ? '生年月日を選択'
              : '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _birthDate == null ? null : _reveal,
          child: const Text('診断する'),
        ),
      ],
    );
  }

  Widget _buildRevealStep(SunSign sign) {
    final element = sign.element;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'あなたは...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 16),
        GradientCard(
          colors: element.gradient,
          child: Column(
            children: [
              Icon(element.icon, color: Colors.white, size: 64),
              const SizedBox(height: 12),
              Text(
                '${element.labelJa}属性',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sign.label,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _finish,
          child: const Text('冒険を始める'),
        ),
      ],
    );
  }
}
