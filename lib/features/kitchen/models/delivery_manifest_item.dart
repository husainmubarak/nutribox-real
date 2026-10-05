import '../../../core/constants/app_constants.dart';

class DeliveryManifestItem {
  final String userId;
  final String namaUser;
  final String targetDiet;
  final String waktuMakan;
  final String alamatId;
  final String labelAlamat;
  final String alamatLengkap;
  final String statusPengiriman;

  const DeliveryManifestItem({
    required this.userId,
    required this.namaUser,
    required this.targetDiet,
    required this.waktuMakan,
    required this.alamatId,
    required this.labelAlamat,
    required this.alamatLengkap,
    required this.statusPengiriman,
  });

  bool get isDelivered => statusPengiriman == AppConstants.statusDikirim;

  DeliveryManifestItem copyWith({
    String? statusPengiriman,
  }) {
    return DeliveryManifestItem(
      userId: userId,
      namaUser: namaUser,
      targetDiet: targetDiet,
      waktuMakan: waktuMakan,
      alamatId: alamatId,
      labelAlamat: labelAlamat,
      alamatLengkap: alamatLengkap,
      statusPengiriman: statusPengiriman ?? this.statusPengiriman,
    );
  }
}
