import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/address_model.dart';
import '../models/package_model.dart';
import '../models/schedule_model.dart';

class SubscriptionRepository {
  final SupabaseClient _client;

  SubscriptionRepository(this._client);

  /// Mengambil daftar paket langganan
  Future<List<PackageModel>> fetchPackages() async {
    final response = await _client
        .from(AppConstants.tablePaketLangganan)
        .select()
        .order('harga', ascending: true);

    return (response as List<dynamic>)
        .map((e) => PackageModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil daftar alamat tersimpan user
  Future<List<AddressModel>> fetchAddresses(String userId) async {
    final response = await _client
        .from(AppConstants.tableAlamatUser)
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    return (response as List<dynamic>)
        .map((e) => AddressModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil daftar mitra dapur yang tersedia
  Future<List<Map<String, dynamic>>> fetchKitchenPartners() async {
    final response = await _client
        .from(AppConstants.tableMitraDapur)
        .select('id, nama_dapur')
        .limit(10);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Menyimpan alamat baru untuk user (otomatis mengaitkan ke mitra_dapur terdekat/utama)
  Future<void> addAddress({
    required String userId,
    required String labelAlamat,
    required String alamatLengkap,
    String? mitraId,
  }) async {
    String? targetMitraId = mitraId;

    // Jika mitraId belum ditentukan, ambil id mitra_dapur pertama yang tersedia di sistem
    if (targetMitraId == null) {
      final kitchens = await fetchKitchenPartners();
      if (kitchens.isNotEmpty) {
        targetMitraId = kitchens.first['id']?.toString();
      }
    }

    await _client.from(AppConstants.tableAlamatUser).insert({
      'user_id': userId,
      'label_alamat': labelAlamat,
      'alamat_lengkap': alamatLengkap,
      'mitra_id': ?targetMitraId,
    });
  }

  /// Menyimpan jadwal pengiriman makanan mingguan
  Future<void> saveSchedule({
    required String userId,
    required List<ScheduleItem> scheduleItems,
  }) async {
    // Hapus jadwal lama user
    await _client
        .from(AppConstants.tableJadwalPengiriman)
        .delete()
        .eq('user_id', userId);

    // Masukkan jadwal baru
    if (scheduleItems.isNotEmpty) {
      final data = scheduleItems.map((item) => item.toMap()).toList();
      await _client.from(AppConstants.tableJadwalPengiriman).insert(data);
    }
  }

  /// Membuat transaksi langganan baru lengkap dengan tanggal mulai & selesai
  Future<void> createSubscription({
    required String userId,
    required int paketId,
    required int durasiHari,
    required int totalHarga,
    required String paymentMethod,
    bool simulateImmediateActive = true,
  }) async {
    final now = DateTime.now();
    final tanggalMulai = DateFormatter.toIsoDateString(now);
    final tanggalSelesai = DateFormatter.toIsoDateString(now.add(Duration(days: durasiHari)));

    // Jika simulasi pembayaran langsung, status_bayar dibuat 'Lunas' agar paket langsung aktif di beranda & dapur
    final statusBayar = simulateImmediateActive
        ? AppConstants.paymentLunas
        : AppConstants.paymentMenunggu;

    await _client.from(AppConstants.tableTransaksiLangganan).insert({
      'user_id': userId,
      'paket_id': paketId,
      'total_harga': totalHarga,
      'status_bayar': statusBayar,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
    });
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SubscriptionRepository(client);
});

/// FutureProvider untuk memuat paket langganan
final packagesFutureProvider = FutureProvider<List<PackageModel>>((ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.fetchPackages();
});

/// FutureProvider untuk memuat alamat tersimpan user
final addressesFutureProvider = FutureProvider<List<AddressModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.fetchAddresses(user.id);
});
