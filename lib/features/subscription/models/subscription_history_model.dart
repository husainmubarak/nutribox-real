class SubscriptionHistoryModel {
  final String id;
  final int? paketId;
  final String namaPaket;
  final int durasiHari;
  final String statusBayar;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final int totalHarga;
  final bool isActive;

  const SubscriptionHistoryModel({
    required this.id,
    this.paketId,
    required this.namaPaket,
    required this.durasiHari,
    required this.statusBayar,
    this.tanggalMulai,
    this.tanggalSelesai,
    required this.totalHarga,
    required this.isActive,
  });

  factory SubscriptionHistoryModel.fromMap(Map<String, dynamic> map) {
    final paketData = map['paket_langganan'];
    String nama = 'Paket Langganan';
    int durasi = 30;

    if (paketData is Map<String, dynamic>) {
      nama = paketData['nama_paket']?.toString() ?? nama;
      durasi = (paketData['durasi_hari'] as num?)?.toInt() ?? durasi;
    } else if (map['nama_paket'] != null) {
      nama = map['nama_paket'].toString();
      durasi = (map['durasi_hari'] as num?)?.toInt() ?? durasi;
    }

    final status = map['status_bayar']?.toString() ?? 'Pending';
    final tglSelesaiStr = map['tanggal_selesai']?.toString();

    // Cek apakah langganan aktif: status Lunas dan tanggal_selesai >= hari ini
    bool active = false;
    if (status.toLowerCase() == 'lunas' && tglSelesaiStr != null) {
      final tglSelesai = DateTime.tryParse(tglSelesaiStr);
      if (tglSelesai != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final expiry = DateTime(tglSelesai.year, tglSelesai.month, tglSelesai.day);
        active = !expiry.isBefore(today);
      }
    }

    return SubscriptionHistoryModel(
      id: map['id']?.toString() ?? '',
      paketId: (map['paket_id'] as num?)?.toInt(),
      namaPaket: nama,
      durasiHari: durasi,
      statusBayar: status,
      tanggalMulai: map['tanggal_mulai']?.toString(),
      tanggalSelesai: tglSelesaiStr,
      totalHarga: (map['total_harga'] as num?)?.toInt() ?? 0,
      isActive: active,
    );
  }
}
