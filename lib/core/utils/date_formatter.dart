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

  /// Memformat string ISO (YYYY-MM-DD) menjadi format ramah Indonesia (contoh: 25 Oktober 2026)
  static String formatIndonesianDate(String? isoDateStr) {
    if (isoDateStr == null || isoDateStr.isEmpty) return '-';
    final d = DateTime.tryParse(isoDateStr);
    if (d == null) return isoDateStr;
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  /// Mengembalikan tanggal hari Senin dari minggu berjalan
  static DateTime getMondayOfCurrentWeek([DateTime? date]) {
    final d = date ?? DateTime.now();
    final clean = DateTime(d.year, d.month, d.day);
    return clean.subtract(Duration(days: clean.weekday - 1));
  }

  /// Memformat tanggal menjadi format pendek (contoh: 14 Okt 2026)
  static String formatShortIndonesianDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
