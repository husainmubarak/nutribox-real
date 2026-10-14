import 'dart:math' as math;

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
        .select('id, nama_dapur, latitude, longitude');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Menyimpan alamat dan mengaitkannya ke dapur dengan koordinat terdekat.
  Future<KitchenAssignment> addAddress({
    required String userId,
    required String labelAlamat,
    required String alamatLengkap,
    required double latitude,
    required double longitude,
  }) async {
    final kitchens = await fetchKitchenPartners();
    KitchenAssignment? nearestKitchen;

    for (final kitchen in kitchens) {
      final kitchenLatitude = (kitchen['latitude'] as num?)?.toDouble();
      final kitchenLongitude = (kitchen['longitude'] as num?)?.toDouble();
      final kitchenId = kitchen['id']?.toString();
      if (kitchenLatitude == null ||
          kitchenLongitude == null ||
          kitchenId == null) {
        continue;
      }

      final distanceKm = _distanceInKilometers(
        latitude,
        longitude,
        kitchenLatitude,
        kitchenLongitude,
      );
      if (nearestKitchen == null || distanceKm < nearestKitchen.distanceKm) {
        nearestKitchen = KitchenAssignment(
          id: kitchenId,
          name: kitchen['nama_dapur']?.toString() ?? 'Dapur Mitra',
          distanceKm: distanceKm,
        );
      }
    }

    if (nearestKitchen == null) {
      throw Exception('Belum ada dapur yang memiliki koordinat lokasi.');
    }

    await _client.from(AppConstants.tableAlamatUser).insert({
      'user_id': userId,
      'label_alamat': labelAlamat,
      'alamat_lengkap': alamatLengkap,
      'latitude': latitude,
      'longitude': longitude,
      'mitra_id': nearestKitchen.id,
    });

    return nearestKitchen;
  }

  double _distanceInKilometers(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadiusKm = 6371.0;
    final deltaLatitude = _degreesToRadians(latitude2 - latitude1);
    final deltaLongitude = _degreesToRadians(longitude2 - longitude1);
    final a =
        math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
        math.cos(_degreesToRadians(latitude1)) *
            math.cos(_degreesToRadians(latitude2)) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);
    final boundedA = a.clamp(0.0, 1.0);
    final centralAngle =
        2 * math.atan2(math.sqrt(boundedA), math.sqrt(1 - boundedA));
    return earthRadiusKm * centralAngle;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

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
  Future<List<SubscriptionHistoryModel>> fetchSubscriptionHistory(
    String userId,
  ) async {
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

    return response.map((e) => SubscriptionHistoryModel.fromMap(e)).toList();
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
      final tglSelesai = DateFormatter.formatIndonesianDate(
        activeSub['tanggal_selesai']?.toString(),
      );
      throw Exception(
        'Anda masih memiliki langganan $nama yang aktif hingga $tglSelesai. Anda baru dapat melakukan transaksi paket baru jika paket sebelumnya sudah selesai.',
      );
    }

    final now = DateTime.now();
    final tanggalMulai = DateFormatter.toIsoDateString(now);
    final tanggalSelesai = DateFormatter.toIsoDateString(
      now.add(Duration(days: durasiHari)),
    );

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

class KitchenAssignment {
  final String id;
  final String name;
  final double distanceKm;

  const KitchenAssignment({
    required this.id,
    required this.name,
    required this.distanceKm,
  });
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
final activeSubscriptionProvider = FutureProvider<Map<String, dynamic>?>((
  ref,
) async {
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
