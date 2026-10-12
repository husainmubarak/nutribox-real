import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/address_model.dart';
import '../models/package_model.dart';
import '../models/schedule_model.dart';
import '../models/subscription_history_model.dart';

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
      // ignore: use_null_aware_elements
      if (targetMitraId != null) 'mitra_id': targetMitraId,
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

  /// Mengambil data langganan aktif user jika ada
  Future<Map<String, dynamic>?> fetchActiveSubscription(String userId) async {
    final tanggalHariIni = DateFormatter.toIsoDateString();
    final response = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('''
          id,
          paket_id,
          status_bayar,
          tanggal_mulai,
          tanggal_selesai,
          total_harga,
          paket_langganan (
            nama_paket,
            durasi_hari
          )
        ''')
        .eq('user_id', userId)
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni)
        .order('tanggal_selesai', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;
    return response.first;
  }

  /// Mengambil seluruh riwayat transaksi langganan user
  Future<List<SubscriptionHistoryModel>> fetchSubscriptionHistory(String userId) async {
    final response = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('''
          id,
          paket_id,
          status_bayar,
          tanggal_mulai,
          tanggal_selesai,
          total_harga,
          paket_langganan (
            nama_paket,
            durasi_hari
          )
        ''')
        .eq('user_id', userId)
        .order('tanggal_mulai', ascending: false);

    return response
        .map((e) => SubscriptionHistoryModel.fromMap(e))
        .toList();
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
    // Validasi aturan bisnis: 1 user hanya bisa memiliki 1 paket langganan aktif dalam satu waktu
    final activeSub = await fetchActiveSubscription(userId);
    if (activeSub != null) {
      final paketData = activeSub['paket_langganan'] as Map<String, dynamic>?;
      final nama = paketData?['nama_paket'] ?? 'paket';
      final tglSelesai = DateFormatter.formatIndonesianDate(activeSub['tanggal_selesai']?.toString());
      throw Exception(
        'Anda masih memiliki langganan $nama yang aktif hingga $tglSelesai. Anda baru dapat melakukan transaksi paket baru jika paket sebelumnya sudah selesai.',
      );
    }

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

/// FutureProvider untuk memuat data langganan aktif user saat ini
final activeSubscriptionProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.fetchActiveSubscription(user.id);
});

/// FutureProvider untuk memuat riwayat transaksi langganan nyata user dari database
final subscriptionHistoryProvider =
    FutureProvider<List<SubscriptionHistoryModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.fetchSubscriptionHistory(user.id);
});
