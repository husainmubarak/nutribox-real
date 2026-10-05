class UserProfile {
  final String id;
  final String namaLengkap;
  final String gender;
  final String tanggalLahir;
  final double tinggiBadan;
  final double beratBadan;
  final String targetDiet;
  final String tingkatAktivitas;
  final String statusBmi;
  final int targetKaloriHarian;

  const UserProfile({
    required this.id,
    required this.namaLengkap,
    required this.gender,
    required this.tanggalLahir,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.targetDiet,
    required this.tingkatAktivitas,
    required this.statusBmi,
    required this.targetKaloriHarian,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      namaLengkap: map['nama_lengkap'] ?? '',
      gender: map['gender'] ?? 'L',
      tanggalLahir: map['tanggal_lahir'] ?? '',
      tinggiBadan: (map['tinggi_badan'] is num)
          ? (map['tinggi_badan'] as num).toDouble()
          : double.tryParse(map['tinggi_badan']?.toString() ?? '170') ?? 170.0,
      beratBadan: (map['berat_badan'] is num)
          ? (map['berat_badan'] as num).toDouble()
          : double.tryParse(map['berat_badan']?.toString() ?? '65') ?? 65.0,
      targetDiet: map['target_diet'] ?? '',
      tingkatAktivitas: map['tingkat_aktivitas']?.toString() ?? '1.2',
      statusBmi: map['status_bmi'] ?? '',
      targetKaloriHarian: (map['target_kalori_harian'] is num)
          ? (map['target_kalori_harian'] as num).toInt()
          : int.tryParse(map['target_kalori_harian']?.toString() ?? '2000') ?? 2000,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'gender': gender,
      'tanggal_lahir': tanggalLahir,
      'tinggi_badan': tinggiBadan,
      'berat_badan': beratBadan,
      'status_bmi': statusBmi,
      'target_diet': targetDiet,
      'tingkat_aktivitas': tingkatAktivitas,
      'target_kalori_harian': targetKaloriHarian,
    };
  }
}
