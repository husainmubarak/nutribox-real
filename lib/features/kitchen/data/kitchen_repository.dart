import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/daily_menu_model.dart';
import '../models/delivery_manifest_item.dart';
import '../models/kitchen_dashboard_data.dart';

class KitchenRepository {
  final SupabaseClient _client;

  KitchenRepository(this._client);

  /// Mengambil data rekap dasbor mitra dapur hari ini
  Future<KitchenDashboardData> fetchDashboardData(String mitraId) async {
    final hariIniString = DateFormatter.getTodayIndonesianDayName();
    final tanggalHariIni = DateFormatter.toIsoDateString();

    // 1. Ambil Nama Dapur
    final dataDapur = await _client
        .from(AppConstants.tableMitraDapur)
        .select('nama_dapur')
        .eq('id', mitraId)
        .limit(1);

    final namaDapur = dataDapur.isNotEmpty
        ? dataDapur.first['nama_dapur'] ?? 'Dapur Mitra'
        : 'Dapur Mitra';

    // 2. Ambil ID Pelanggan yang paket langganannya aktif hari ini
    final daftarTransaksiAktif = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('user_id')
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni);

    final Set<String> listUserAktif = (daftarTransaksiAktif as List<dynamic>)
        .map((t) => t['user_id'].toString())
        .toSet();

    // 3. Tarik jadwal pengiriman hari ini
    final jadwalRaw = await _client
        .from(AppConstants.tableJadwalPengiriman)
        .select('''
          waktu_makan, 
          user_id,
          users!inner (target_diet),
          alamat_user (mitra_id)
        ''')
        .eq('hari', hariIniString);

    // 4. Proses Rekap Porsi Berdasarkan Program Diet
    final Map<String, int> hitungSementara = {};
    int hitungTotal = 0;

    for (var jadwal in (jadwalRaw as List<dynamic>)) {
      final userId = jadwal['user_id']?.toString() ?? '';

      // Periksa apakah alamat terkait dengan mitra dapur ini (atau belum ditentukan/null)
      final alamatData = jadwal['alamat_user'];
      final String? assignedMitraId = (alamatData is Map)
          ? alamatData['mitra_id']?.toString()
          : (alamatData is List && alamatData.isNotEmpty)
          ? alamatData[0]['mitra_id']?.toString()
          : null;

      final isMatchingMitra = assignedMitraId == mitraId;

      if (isMatchingMitra && listUserAktif.contains(userId)) {
        final usersData = jadwal['users'];
        final rawDiet = (usersData is Map)
            ? usersData['target_diet']?.toString()
            : null;
        final diet = (rawDiet == 'Diet')
            ? 'Cutting'
            : (rawDiet ?? 'Tidak Diketahui');

        hitungSementara[diet] = (hitungSementara[diet] ?? 0) + 1;
        hitungTotal++;
      }
    }

    return KitchenDashboardData(
      namaDapur: namaDapur,
      hariIni: hariIniString,
      totalPorsi: hitungTotal,
      rekapPesanan: hitungSementara,
    );
  }

  /// Menyimpan menu harian yang dimasak oleh chef dapur
  Future<void> saveDailyMenu(DailyMenuModel menu) async {
    final mitraId = menu.mitraId;
    if (mitraId == null || mitraId.isEmpty) {
      throw Exception('ID mitra dapur diperlukan untuk menyimpan menu');
    }

    // Normalisasi 'Diet' ke 'Cutting' agar konsisten dengan pelanggan
    final normalizedDiet = menu.targetDiet == 'Diet'
        ? 'Cutting'
        : menu.targetDiet;

    // Cek apakah menu untuk tanggal, target_diet, dan waktu_makan ini sudah ada
    final existingMenu = await _client
        .from(AppConstants.tableMasterMenuHarian)
        .select('id')
        .eq('mitra_id', mitraId)
        .eq('tanggal', menu.tanggal)
        .eq('target_diet', normalizedDiet)
        .eq('waktu_makan', menu.waktuMakan)
        .limit(1);

    if (existingMenu.isNotEmpty) {
      // Update menu yang sudah ada
      await _client
          .from(AppConstants.tableMasterMenuHarian)
          .update({'nama_menu': menu.namaMenu, 'deskripsi': menu.deskripsi})
          .eq('id', existingMenu.first['id']);
    } else {
      // Insert menu baru
      await _client.from(AppConstants.tableMasterMenuHarian).insert({
        'mitra_id': mitraId,
        'tanggal': menu.tanggal,
        'target_diet': normalizedDiet,
        'waktu_makan': menu.waktuMakan,
        'nama_menu': menu.namaMenu,
        'deskripsi': menu.deskripsi,
      });
    }
  }

  /// Mengambil daftar manifest pengiriman makanan hari ini untuk kurir/dapur
  Future<List<DeliveryManifestItem>> fetchDeliveryManifest(
    String mitraId,
  ) async {
    final hariIniString = DateFormatter.getTodayIndonesianDayName();
    final tanggalHariIni = DateFormatter.toIsoDateString();

    // 1. Ambil list user aktif
    final daftarTransaksi = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('user_id')
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni);

    final Set<String> userAktif = (daftarTransaksi as List<dynamic>)
        .map((t) => t['user_id'].toString())
        .toSet();

    // 2. Tarik jadwal pengiriman hari ini
    final jadwalRaw = await _client
        .from(AppConstants.tableJadwalPengiriman)
        .select('''
          waktu_makan, 
          user_id,
          alamat_id,
          users!inner (nama_lengkap, target_diet),
          alamat_user (label_alamat, alamat_lengkap, mitra_id)
        ''')
        .eq('hari', hariIniString);

    // 3. Tarik log pengiriman hari ini (tabel menu_harian)
    final logHariIni = await _client
        .from(AppConstants.tableMenuHarian)
        .select('user_id, waktu_makan, status_pengiriman')
        .eq('tanggal', tanggalHariIni);

    // FIX MAJOR BUG: String interpolation key yang valid
    final Map<String, String> statusMap = {};
    for (var log in (logHariIni as List<dynamic>)) {
      final key = "${log['user_id']}_${log['waktu_makan']}";
      statusMap[key] =
          log['status_pengiriman']?.toString() ?? AppConstants.statusDimasak;
    }

    final List<DeliveryManifestItem> manifestItems = [];

    for (var item in (jadwalRaw as List<dynamic>)) {
      final userId = item['user_id']?.toString() ?? '';
      if (!userAktif.contains(userId)) continue;

      final alamatMentah = item['alamat_user'];
      final Map<String, dynamic> alamatData =
          (alamatMentah is List && alamatMentah.isNotEmpty)
          ? alamatMentah[0] as Map<String, dynamic>
          : (alamatMentah is Map)
          ? alamatMentah as Map<String, dynamic>
          : {};

      final assignedMitraId = alamatData['mitra_id']?.toString();
      if (assignedMitraId != mitraId) {
        continue;
      }

      final userData = (item['users'] is Map)
          ? item['users'] as Map<String, dynamic>
          : {};
      final namaUser = userData['nama_lengkap']?.toString() ?? 'Pelanggan';
      final targetDiet = userData['target_diet']?.toString() ?? '-';
      final waktuMakan = item['waktu_makan']?.toString() ?? '-';
      final alamatId = item['alamat_id']?.toString() ?? '';
      final labelAlamat =
          alamatData['label_alamat']?.toString() ?? 'Alamat Belum Diberi Label';
      final alamatLengkap =
          alamatData['alamat_lengkap']?.toString() ??
          'Alamat lengkap belum diisi';

      // FIX MAJOR BUG: Kunci status dengan format ${userId}_$waktuMakan
      final statusKey = "${userId}_$waktuMakan";
      final statusSaatIni = statusMap[statusKey] ?? AppConstants.statusDimasak;

      manifestItems.add(
        DeliveryManifestItem(
          userId: userId,
          namaUser: namaUser,
          targetDiet: targetDiet,
          waktuMakan: waktuMakan,
          alamatId: alamatId,
          labelAlamat: labelAlamat,
          alamatLengkap: alamatLengkap,
          statusPengiriman: statusSaatIni,
        ),
      );
    }

    return manifestItems;
  }

  /// Menandai makanan telah dikirim ke pelanggan
  Future<void> markAsDelivered({
    required String userId,
    required String waktuMakan,
    required String alamatId,
  }) async {
    final tanggalHariIni = DateFormatter.toIsoDateString();
    final mitraId = _client.auth.currentUser?.id;
    if (mitraId == null) {
      throw Exception('Mitra dapur belum terautentikasi');
    }

    final profilPelanggan = await _client
        .from(AppConstants.tableUsers)
        .select('target_diet')
        .eq('id', userId)
        .limit(1);
    final targetDiet = profilPelanggan.isNotEmpty
        ? profilPelanggan.first['target_diet']?.toString()
        : null;

    Map<String, dynamic>? menuMaster;
    if (targetDiet != null) {
      final menuMasterRows = await _client
          .from(AppConstants.tableMasterMenuHarian)
          .select('id, nama_menu')
          .eq('mitra_id', mitraId)
          .eq('tanggal', tanggalHariIni)
          .eq('target_diet', targetDiet == 'Diet' ? 'Cutting' : targetDiet)
          .eq('waktu_makan', waktuMakan)
          .limit(1);
      if (menuMasterRows.isNotEmpty) {
        menuMaster = Map<String, dynamic>.from(menuMasterRows.first);
      }
    }

    final updateData = <String, dynamic>{
      'status_pengiriman': AppConstants.statusTerkirim,
      if (menuMaster != null) 'master_menu_id': menuMaster['id'],
      if (menuMaster != null) 'nama_menu': menuMaster['nama_menu'],
    };

    final cekLog = await _client
        .from(AppConstants.tableMenuHarian)
        .select('id')
        .eq('tanggal', tanggalHariIni)
        .eq('user_id', userId)
        .eq('waktu_makan', waktuMakan)
        .limit(1);

    if (cekLog.isNotEmpty) {
      await _client
          .from(AppConstants.tableMenuHarian)
          .update(updateData)
          .eq('id', cekLog.first['id']);
    } else {
      await _client.from(AppConstants.tableMenuHarian).insert({
        'user_id': userId,
        'tanggal': tanggalHariIni,
        'waktu_makan': waktuMakan,
        'status_pengiriman': AppConstants.statusTerkirim,
        'alamat_id': alamatId,
        if (menuMaster != null) 'master_menu_id': menuMaster['id'],
        if (menuMaster != null) 'nama_menu': menuMaster['nama_menu'],
      });
    }
  }
}

final kitchenRepositoryProvider = Provider<KitchenRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return KitchenRepository(client);
});

/// FutureProvider data dasbor mitra
final kitchenDashboardProvider = FutureProvider<KitchenDashboardData>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('Mitra belum terautentikasi');
  }
  final repo = ref.watch(kitchenRepositoryProvider);
  return repo.fetchDashboardData(user.id);
});

/// FutureProvider manifest pengiriman hari ini
final deliveryManifestProvider = FutureProvider<List<DeliveryManifestItem>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('Mitra belum terautentikasi');
  }
  final repo = ref.watch(kitchenRepositoryProvider);
  return repo.fetchDeliveryManifest(user.id);
});
