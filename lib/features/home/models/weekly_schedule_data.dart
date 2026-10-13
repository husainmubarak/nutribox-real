import 'home_dashboard_data.dart';

class WeeklyScheduleData {
  final bool adaPaketAktif;
  final String targetDiet;
  final int targetKalori;
  final String hariIni;
  final Map<String, List<ScheduledMealItem>> jadwalPerHari;
  final Map<String, String> tanggalFormattedPerHari;
  final Map<String, String> tanggalIsoPerHari;

  const WeeklyScheduleData({
    required this.adaPaketAktif,
    required this.targetDiet,
    required this.targetKalori,
    required this.hariIni,
    required this.jadwalPerHari,
    required this.tanggalFormattedPerHari,
    required this.tanggalIsoPerHari,
  });
}
