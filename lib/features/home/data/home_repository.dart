import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/home_dashboard_data.dart';

class HomeRepository {
  final SupabaseClient _client;

  HomeRepository(this._client);

  Future<HomeDashboardData> fetchDashboardData(String userId) async {
    final hariIniString = DateFormatter.getTodayIndonesianDayName();
    final tanggalHariIni = DateFormatter.toIsoDateString();

    // 1. Tarik profil user (nama dan target diet)
    final profileResponse = await _client
        .from(AppConstants.tableUsers)
        .select('nama_lengkap, target_diet')
        .eq('id', userId)
        .maybeSingle();

    final namaUser = profileResponse?['nama_lengkap'] ?? 'Pelanggan';
    final targetDiet = profileResponse?['target_diet'] ?? 'Belum ada target';

    // 2. Cek status paket langganan aktif
    final packageResponse = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('id')
        .eq('user_id', userId)
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni)
        .maybeSingle();

    final adaPaketAktif = packageResponse != null;

    // 3. Tarik Master Menu Harian khusus target diet user hari ini
    final Map<String, String> mapMenuHariIni = {};
    if (targetDiet != 'Belum ada target') {
      // Normalisasi nama target jika ada perbedaan kata (misal 'Diet' -> 'Cutting')
      final normalizedDiet = targetDiet == 'Diet' ? 'Cutting' : targetDiet;

      final menuResponse = await _client
          .from(AppConstants.tableMasterMenuHarian)
          .select('waktu_makan, nama_menu')
          .eq('tanggal', tanggalHariIni)
          .or('target_diet.eq.$targetDiet,target_diet.eq.$normalizedDiet');

      for (var menu in (menuResponse as List<dynamic>)) {
        mapMenuHariIni[menu['waktu_makan']?.toString() ?? ''] =
            menu['nama_menu']?.toString() ?? '';
      }
    }

    // 4. Tarik daftar alamat tersimpan user untuk memetakan ID alamat ke Label
    final addressResponse = await _client
        .from(AppConstants.tableAlamatUser)
        .select('id, label_alamat')
        .eq('user_id', userId);

    final Map<String, String> mapAlamat = {};
    for (var addr in (addressResponse as List<dynamic>)) {
      mapAlamat[addr['id'].toString()] = addr['label_alamat']?.toString() ?? '';
    }

    // 5. Tarik jadwal pengiriman untuk hari ini
    final scheduleResponse = await _client
        .from(AppConstants.tableJadwalPengiriman)
        .select()
        .eq('user_id', userId)
        .eq('hari', hariIniString);

    final orderUrutanWaktu = {
      AppConstants.mealSarapan: 1,
      AppConstants.mealSiang: 2,
      AppConstants.mealMalam: 3,
    };

    final rawList = List<Map<String, dynamic>>.from(scheduleResponse);
    rawList.sort((a, b) {
      final orderA = orderUrutanWaktu[a['waktu_makan']] ?? 99;
      final orderB = orderUrutanWaktu[b['waktu_makan']] ?? 99;
      return orderA.compareTo(orderB);
    });

    final List<ScheduledMealItem> scheduledMeals = rawList.map((j) {
      final waktuMakan = j['waktu_makan']?.toString() ?? '';
      final alamatId = j['alamat_id']?.toString() ?? '';
      final namaAlamat = mapAlamat[alamatId] ?? 'Alamat tidak diketahui';
      final namaMenu =
          mapMenuHariIni[waktuMakan] ?? 'Menu spesial Chef (Kejutan!)';

      return ScheduledMealItem(
        waktuMakan: waktuMakan,
        namaMenu: namaMenu,
        namaAlamat: namaAlamat,
      );
    }).toList();

    return HomeDashboardData(
      namaUser: namaUser,
      targetDiet: targetDiet,
      hariIni: hariIniString,
      adaPaketAktif: adaPaketAktif,
      jadwalHariIni: scheduledMeals,
    );
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HomeRepository(client);
});

/// FutureProvider untuk memuat data dashboard beranda pelanggan
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User belum terautentikasi');
  }
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchDashboardData(user.id);
});
