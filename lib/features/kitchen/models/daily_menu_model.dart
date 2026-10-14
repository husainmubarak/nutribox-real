class DailyMenuModel {
  final int? id;
  final String? mitraId;
  final String tanggal;
  final String targetDiet;
  final String waktuMakan;
  final String namaMenu;
  final String deskripsi;

  const DailyMenuModel({
    this.id,
    this.mitraId,
    required this.tanggal,
    required this.targetDiet,
    required this.waktuMakan,
    required this.namaMenu,
    required this.deskripsi,
  });

  factory DailyMenuModel.fromMap(Map<String, dynamic> map) {
    return DailyMenuModel(
      id: (map['id'] is num)
          ? (map['id'] as num).toInt()
          : int.tryParse(map['id']?.toString() ?? ''),
      mitraId: map['mitra_id']?.toString() ?? '',
      tanggal: map['tanggal'] ?? '',
      targetDiet: map['target_diet'] ?? '',
      waktuMakan: map['waktu_makan'] ?? '',
      namaMenu: map['nama_menu'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (mitraId != null) 'mitra_id': mitraId,
      'tanggal': tanggal,
      'target_diet': targetDiet,
      'waktu_makan': waktuMakan,
      'nama_menu': namaMenu,
      'deskripsi': deskripsi,
    };
  }
}
