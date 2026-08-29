import 'cosmic_element.dart';

enum SunSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

extension SunSignInfo on SunSign {
  String get label {
    switch (this) {
      case SunSign.aries:
        return 'Aries';
      case SunSign.taurus:
        return 'Taurus';
      case SunSign.gemini:
        return 'Gemini';
      case SunSign.cancer:
        return 'Cancer';
      case SunSign.leo:
        return 'Leo';
      case SunSign.virgo:
        return 'Virgo';
      case SunSign.libra:
        return 'Libra';
      case SunSign.scorpio:
        return 'Scorpio';
      case SunSign.sagittarius:
        return 'Sagittarius';
      case SunSign.capricorn:
        return 'Capricorn';
      case SunSign.aquarius:
        return 'Aquarius';
      case SunSign.pisces:
        return 'Pisces';
    }
  }

  CosmicElement get element {
    switch (this) {
      case SunSign.aries:
      case SunSign.leo:
      case SunSign.sagittarius:
        return CosmicElement.fire;
      case SunSign.taurus:
      case SunSign.virgo:
      case SunSign.capricorn:
        return CosmicElement.earth;
      case SunSign.gemini:
      case SunSign.libra:
      case SunSign.aquarius:
        return CosmicElement.air;
      case SunSign.cancer:
      case SunSign.scorpio:
      case SunSign.pisces:
        return CosmicElement.water;
    }
  }
}

/// 生年月日から太陽星座を算出する静的マッピング（西洋占星術の一般的な日付区分）。
SunSign sunSignFromBirthDate(DateTime date) {
  final m = date.month;
  final d = date.day;

  bool inRange(int startMonth, int startDay, int endMonth, int endDay) {
    if (startMonth == m && d >= startDay) return true;
    if (endMonth == m && d <= endDay) return true;
    return false;
  }

  if (inRange(3, 21, 4, 19)) return SunSign.aries;
  if (inRange(4, 20, 5, 20)) return SunSign.taurus;
  if (inRange(5, 21, 6, 20)) return SunSign.gemini;
  if (inRange(6, 21, 7, 22)) return SunSign.cancer;
  if (inRange(7, 23, 8, 22)) return SunSign.leo;
  if (inRange(8, 23, 9, 22)) return SunSign.virgo;
  if (inRange(9, 23, 10, 22)) return SunSign.libra;
  if (inRange(10, 23, 11, 21)) return SunSign.scorpio;
  if (inRange(11, 22, 12, 21)) return SunSign.sagittarius;
  if (inRange(12, 22, 1, 19)) return SunSign.capricorn;
  if (inRange(1, 20, 2, 18)) return SunSign.aquarius;
  return SunSign.pisces; // 2/19 - 3/20
}
