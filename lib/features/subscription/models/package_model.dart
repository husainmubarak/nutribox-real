class PackageModel {
  final int id;
  final String namaPaket;
  final int durasiHari;
  final int harga;

  const PackageModel({
    required this.id,
    required this.namaPaket,
    required this.durasiHari,
    required this.harga,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: (map['id'] is num)
          ? (map['id'] as num).toInt()
          : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      namaPaket: map['nama_paket'] ?? '',
      durasiHari: (map['durasi_hari'] is num)
          ? (map['durasi_hari'] as num).toInt()
          : int.tryParse(map['durasi_hari']?.toString() ?? '30') ?? 30,
      harga: (map['harga'] is num)
          ? (map['harga'] as num).toInt()
          : int.tryParse(map['harga']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_paket': namaPaket,
      'durasi_hari': durasiHari,
      'harga': harga,
    };
  }
}
