class ScheduledMealItem {
  final String waktuMakan;
  final String namaMenu;
  final String namaAlamat;

  const ScheduledMealItem({
    required this.waktuMakan,
    required this.namaMenu,
    required this.namaAlamat,
  });
}

class HomeDashboardData {
  final String namaUser;
  final String targetDiet;
  final String hariIni;
  final bool adaPaketAktif;
  final List<ScheduledMealItem> jadwalHariIni;

  const HomeDashboardData({
    required this.namaUser,
    required this.targetDiet,
    required this.hariIni,
    required this.adaPaketAktif,
    required this.jadwalHariIni,
  });
}
