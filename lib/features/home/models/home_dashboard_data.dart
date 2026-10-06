class ScheduledMealItem {
  final String waktuMakan;
  final String namaMenu;
  final String namaAlamat;
  final String? jamKirim;
  final String? statusPengiriman;

  const ScheduledMealItem({
    required this.waktuMakan,
    required this.namaMenu,
    required this.namaAlamat,
    this.jamKirim,
    this.statusPengiriman,
  });
}

class HomeDashboardData {
  final String namaUser;
  final String targetDiet;
  final String hariIni;
  final bool adaPaketAktif;
  final List<ScheduledMealItem> jadwalHariIni;
  final String statusBmi;
  final int targetKalori;
  final int sisaHari;
  final int totalHari;
  final String namaPaket;

  const HomeDashboardData({
    required this.namaUser,
    required this.targetDiet,
    required this.hariIni,
    required this.adaPaketAktif,
    required this.jadwalHariIni,
    this.statusBmi = 'Ideal',
    this.targetKalori = 2000,
    this.sisaHari = 0,
    this.totalHari = 30,
    this.namaPaket = 'Paket Sehat',
  });
}
