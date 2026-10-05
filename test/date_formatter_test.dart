import 'package:flutter_test/flutter_test.dart';
import 'package:nutribox/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('calculateAge calculates exact age accurately', () {
      final birthDate = DateTime(2000, 5, 15);
      final currentDateBeforeBirthday = DateTime(2026, 5, 14);
      final currentDateOnBirthday = DateTime(2026, 5, 15);
      final currentDateAfterBirthday = DateTime(2026, 5, 16);

      expect(DateFormatter.calculateAge(birthDate, currentDateBeforeBirthday), 25);
      expect(DateFormatter.calculateAge(birthDate, currentDateOnBirthday), 26);
      expect(DateFormatter.calculateAge(birthDate, currentDateAfterBirthday), 26);
    });

    test('toIsoDateString formats date to YYYY-MM-DD correctly', () {
      final date = DateTime(2026, 9, 29);
      expect(DateFormatter.toIsoDateString(date), '2026-09-29');

      final dateSingleDigits = DateTime(2026, 1, 5);
      expect(DateFormatter.toIsoDateString(dateSingleDigits), '2026-01-05');
    });

    test('getTodayIndonesianDayName returns correct Indonesian day names', () {
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 9, 28)), 'Senin'); // Monday
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 9, 29)), 'Selasa'); // Tuesday
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 9, 30)), 'Rabu'); // Wednesday
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 10, 1)), 'Kamis'); // Thursday
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 10, 2)), 'Jumat'); // Friday
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 10, 3)), 'Sabtu'); // Saturday
      expect(DateFormatter.getTodayIndonesianDayName(DateTime(2026, 10, 4)), 'Minggu'); // Sunday
    });
  });
}
