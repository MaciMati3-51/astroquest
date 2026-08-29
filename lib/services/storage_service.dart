import 'package:shared_preferences/shared_preferences.dart';
import '../models/cosmic_element.dart';

/// 端末内保存のみ（サーバー・認証なし）。
class StorageService {
  StorageService._(this._prefs);
  final SharedPreferences _prefs;

  static StorageService? _instance;

  static Future<StorageService> load() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    return _instance!;
  }

  static const _kOnboardingDone = 'onboarding_done';
  static const _kBirthDate = 'birth_date';
  static const _kElement = 'element';
  static const _kIsPro = 'is_pro';
  static const _kStreakCount = 'streak_count';
  static const _kLastCompletionDate = 'last_completion_date';
  static const _kCompletionDates = 'completion_dates';
  static const _kUnlockedTalismans = 'unlocked_talismans';

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool v) => _prefs.setBool(_kOnboardingDone, v);

  DateTime? get birthDate {
    final s = _prefs.getString(_kBirthDate);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> setBirthDate(DateTime d) =>
      _prefs.setString(_kBirthDate, d.toIso8601String());

  CosmicElement? get element {
    final s = _prefs.getString(_kElement);
    if (s == null) return null;
    return CosmicElement.values.firstWhere((e) => e.name == s);
  }

  Future<void> setElement(CosmicElement e) =>
      _prefs.setString(_kElement, e.name);

  bool get isPro => _prefs.getBool(_kIsPro) ?? false;
  Future<void> setIsPro(bool v) => _prefs.setBool(_kIsPro, v);

  int get streakCount => _prefs.getInt(_kStreakCount) ?? 0;

  DateTime? get lastCompletionDate {
    final s = _prefs.getString(_kLastCompletionDate);
    return s == null ? null : DateTime.tryParse(s);
  }

  List<DateTime> get completionDates {
    final list = _prefs.getStringList(_kCompletionDates) ?? [];
    return list.map((s) => DateTime.parse(s)).toList();
  }

  List<String> get unlockedTalismanIds =>
      _prefs.getStringList(_kUnlockedTalismans) ?? [];

  bool get completedToday {
    final last = lastCompletionDate;
    if (last == null) return false;
    final now = DateTime.now();
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  /// クエスト達成を記録し、Streakを更新し、抽選したタリスマンIDを返す。
  Future<String> recordCompletion(String drawnTalismanId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = lastCompletionDate;

    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        newStreak = streakCount; // 既に本日達成済み
      } else if (diff == 1) {
        newStreak = streakCount + 1;
      } else {
        newStreak = 1;
      }
    }

    await _prefs.setInt(_kStreakCount, newStreak);
    await _prefs.setString(_kLastCompletionDate, today.toIso8601String());

    final dates = completionDates;
    final alreadyLogged = dates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
    if (!alreadyLogged) {
      dates.add(today);
      await _prefs.setStringList(
        _kCompletionDates,
        dates.map((d) => d.toIso8601String()).toList(),
      );
    }

    final unlocked = unlockedTalismanIds;
    if (!unlocked.contains(drawnTalismanId)) {
      unlocked.add(drawnTalismanId);
      await _prefs.setStringList(_kUnlockedTalismans, unlocked);
    }

    return drawnTalismanId;
  }
}
