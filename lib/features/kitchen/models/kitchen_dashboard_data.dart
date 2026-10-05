class KitchenDashboardData {
  final String namaDapur;
  final String hariIni;
  final int totalPorsi;
  final Map<String, int> rekapPesanan;

  const KitchenDashboardData({
    required this.namaDapur,
    required this.hariIni,
    required this.totalPorsi,
    required this.rekapPesanan,
  });
}
