class DailyMenuModel {
  final int? id;
  final String tanggal;
  final String targetDiet;
  final String waktuMakan;
  final String namaMenu;
  final String deskripsi;

  const DailyMenuModel({
    this.id,
    required this.tanggal,
    required this.targetDiet,
    required this.waktuMakan,
    required this.namaMenu,
    required this.deskripsi,
  });

  factory DailyMenuModel.fromMap(Map<String, dynamic> map) {
    return DailyMenuModel(
      id: (map['id'] is num) ? (map['id'] as num).toInt() : int.tryParse(map['id']?.toString() ?? ''),
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
      'tanggal': tanggal,
      'target_diet': targetDiet,
      'waktu_makan': waktuMakan,
      'nama_menu': namaMenu,
      'deskripsi': deskripsi,
    };
  }
}
