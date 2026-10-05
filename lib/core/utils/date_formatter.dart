class DateFormatter {
  DateFormatter._();

  /// Mengembalikan nama hari dalam Bahasa Indonesia (Senin - Minggu)
  static String getTodayIndonesianDayName([DateTime? date]) {
    final d = date ?? DateTime.now();
    switch (d.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  /// Mengembalikan format tanggal YYYY-MM-DD
  static String toIsoDateString([DateTime? date]) {
    final d = date ?? DateTime.now();
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  /// Menghitung umur berdasarkan tanggal lahir
  static int calculateAge(DateTime birthDate, [DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
