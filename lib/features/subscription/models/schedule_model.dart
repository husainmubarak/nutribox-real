class ScheduleItem {
  final String? id;
  final String userId;
  final String hari;
  final String waktuMakan;
  final String alamatId;

  const ScheduleItem({
    this.id,
    required this.userId,
    required this.hari,
    required this.waktuMakan,
    required this.alamatId,
  });

  factory ScheduleItem.fromMap(Map<String, dynamic> map) {
    return ScheduleItem(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      hari: map['hari'] ?? '',
      waktuMakan: map['waktu_makan'] ?? '',
      alamatId: map['alamat_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'hari': hari,
      'waktu_makan': waktuMakan,
      'alamat_id': alamatId,
    };
  }
}
