class AddressModel {
  final String id;
  final String userId;
  final String labelAlamat;
  final String alamatLengkap;
  final String? mitraId;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.labelAlamat,
    required this.alamatLengkap,
    this.mitraId,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      labelAlamat: map['label_alamat'] ?? '',
      alamatLengkap: map['alamat_lengkap'] ?? '',
      mitraId: map['mitra_id']?.toString(),
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      AddressModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'label_alamat': labelAlamat,
      'alamat_lengkap': alamatLengkap,
      'mitra_id': ?mitraId,
    };
  }
}
