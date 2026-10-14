class AddressModel {
  final String id;
  final String userId;
  final String labelAlamat;
  final String alamatLengkap;
  final String? mitraId;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.labelAlamat,
    required this.alamatLengkap,
    this.mitraId,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      labelAlamat: map['label_alamat'] ?? '',
      alamatLengkap: map['alamat_lengkap'] ?? '',
      mitraId: map['mitra_id']?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
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
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
