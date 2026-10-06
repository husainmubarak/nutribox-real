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

    // 1. Tarik profil user (nama, target diet, status BMI, target kalori)
    final profileResponse = await _client
        .from(AppConstants.tableUsers)
        .select('nama_lengkap, target_diet, status_bmi, target_kalori_harian')
        .eq('id', userId)
        .maybeSingle();

    final namaUser = profileResponse?['nama_lengkap'] ?? 'Pelanggan';
    final targetDiet = profileResponse?['target_diet'] ?? 'Belum ada target';
    final statusBmi = profileResponse?['status_bmi'] ?? 'Ideal';
    final targetKalori = (profileResponse?['target_kalori_harian'] as num?)?.toInt() ?? 2000;

    // 2. Cek status paket langganan aktif
    final packageResponse = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('id, paket_id, tanggal_mulai, tanggal_selesai')
        .eq('user_id', userId)
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni)
        .order('tanggal_selesai', ascending: false)
        .maybeSingle();

    final adaPaketAktif = packageResponse != null;
    int sisaHari = 0;
    int totalHari = 30;
    String namaPaket = 'Paket Langganan';

    if (adaPaketAktif) {
      final tglSelesaiStr = packageResponse['tanggal_selesai']?.toString();
      final tglMulaiStr = packageResponse['tanggal_mulai']?.toString();
      if (tglSelesaiStr != null) {
        final tglSelesai = DateTime.tryParse(tglSelesaiStr);
        final now = DateTime.now();
        if (tglSelesai != null) {
          sisaHari = tglSelesai.difference(now).inDays + 1;
          if (sisaHari < 0) sisaHari = 0;
        }
      }
      if (tglMulaiStr != null && tglSelesaiStr != null) {
        final tglMulai = DateTime.tryParse(tglMulaiStr);
        final tglSelesai = DateTime.tryParse(tglSelesaiStr);
        if (tglMulai != null && tglSelesai != null) {
          totalHari = tglSelesai.difference(tglMulai).inDays + 1;
        }
      }

      final paketId = packageResponse['paket_id'];
      if (paketId != null) {
        final pResponse = await _client
            .from(AppConstants.tablePaketLangganan)
            .select('nama_paket')
            .eq('id', paketId)
            .maybeSingle();
        if (pResponse != null && pResponse['nama_paket'] != null) {
          namaPaket = pResponse['nama_paket'];
        }
      }
    }

    // 3. Tarik Master Menu Harian khusus target diet user hari ini
    final Map<String, String> mapMenuHariIni = {};
    if (targetDiet != 'Belum ada target') {
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

    final defaultJam = {
      AppConstants.mealSarapan: '07:00 - 08:00',
      AppConstants.mealSiang: '11:30 - 12:30',
      AppConstants.mealMalam: '18:00 - 19:00',
    };

    final List<ScheduledMealItem> scheduledMeals = rawList.map((j) {
      final waktuMakan = j['waktu_makan']?.toString() ?? '';
      final alamatId = j['alamat_id']?.toString() ?? '';
      final namaAlamat = mapAlamat[alamatId] ?? 'Alamat Tersimpan';
      final namaMenu =
          mapMenuHariIni[waktuMakan] ?? 'Menu Sehat Pilihan Chef';

      return ScheduledMealItem(
        waktuMakan: waktuMakan,
        namaMenu: namaMenu,
        namaAlamat: namaAlamat,
        jamKirim: defaultJam[waktuMakan] ?? '12:00',
        statusPengiriman: 'Dimasak',
      );
    }).toList();

    return HomeDashboardData(
      namaUser: namaUser,
      targetDiet: targetDiet,
      hariIni: hariIniString,
      adaPaketAktif: adaPaketAktif,
      jadwalHariIni: scheduledMeals,
      statusBmi: statusBmi,
      targetKalori: targetKalori,
      sisaHari: sisaHari,
      totalHari: totalHari,
      namaPaket: namaPaket,
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
