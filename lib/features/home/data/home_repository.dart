import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/home_dashboard_data.dart';
import '../models/weekly_schedule_data.dart';

class HomeRepository {
  final SupabaseClient _client;

  HomeRepository(this._client);

  String _statusUntukTampilan(String? status) {
    if (status == 'Dikirim') return AppConstants.statusTerkirim;
    return status ?? '';
  }

  Future<HomeDashboardData> fetchDashboardData(String userId) async {
    final hariIniString = DateFormatter.getTodayIndonesianDayName();
    final tanggalHariIni = DateFormatter.toIsoDateString();

    // 1. Tarik profil user (nama, target diet, status BMI, target kalori)
    final profileResponse = await _client
        .from(AppConstants.tableUsers)
        .select('nama_lengkap, target_diet, status_bmi, target_kalori_harian')
        .eq('id', userId)
        .limit(1);

    final Map<String, dynamic>? profileData = profileResponse.isNotEmpty
        ? profileResponse.first
        : null;

    final namaUser = profileData?['nama_lengkap'] ?? 'Pelanggan';
    final targetDiet = profileData?['target_diet'] ?? 'Belum ada target';
    final statusBmi = profileData?['status_bmi'] ?? 'Ideal';
    final targetKalori =
        (profileData?['target_kalori_harian'] as num?)?.toInt() ?? 2000;

    // 2. Cek status paket langganan aktif (ambil paket aktif terbaru/terlama berakhir)
    final packageResponseList = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('id, paket_id, tanggal_mulai, tanggal_selesai')
        .eq('user_id', userId)
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni)
        .order('tanggal_selesai', ascending: false)
        .limit(1);

    final Map<String, dynamic>? packageResponse = packageResponseList.isNotEmpty
        ? packageResponseList.first
        : null;

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
            .limit(1);
        if (pResponse.isNotEmpty && pResponse.first['nama_paket'] != null) {
          namaPaket = pResponse.first['nama_paket'];
        }
      }
    }

    // 3. Tarik alamat dan jadwal agar menu dapat dipilih dari dapur yang melayani alamat.
    final addressResponse = await _client
        .from(AppConstants.tableAlamatUser)
        .select('id, label_alamat, mitra_id')
        .eq('user_id', userId);

    final Map<String, String> mapAlamat = {};
    final Map<String, String> mapDapurAlamat = {};
    for (var addr in (addressResponse as List<dynamic>)) {
      final addressId = addr['id'].toString();
      mapAlamat[addressId] = addr['label_alamat']?.toString() ?? '';
      final kitchenId = addr['mitra_id']?.toString();
      if (kitchenId != null) mapDapurAlamat[addressId] = kitchenId;
    }

    // 4. Tarik jadwal hari ini dan ID dapur yang melayani slot tersebut.
    final scheduleResponse = await _client
        .from(AppConstants.tableJadwalPengiriman)
        .select('waktu_makan, alamat_id')
        .eq('user_id', userId)
        .eq('hari', hariIniString);

    final kitchenIdsToday = (scheduleResponse as List<dynamic>)
        .map((j) => mapDapurAlamat[j['alamat_id']?.toString() ?? ''])
        .whereType<String>()
        .toSet()
        .toList();

    // Ambil status pengiriman hari ini agar kartu Beranda konsisten dengan
    // tab Jadwal dan status yang diperbarui oleh dapur melalui manifest.
    final deliveryLogResponse = await _client
        .from(AppConstants.tableMenuHarian)
        .select('waktu_makan, status_pengiriman')
        .eq('user_id', userId)
        .eq('tanggal', tanggalHariIni);

    final Map<String, String> statusPengirimanHariIni = {};
    for (final log in (deliveryLogResponse as List<dynamic>)) {
      final waktuMakan = log['waktu_makan']?.toString();
      final status = _statusUntukTampilan(
        log['status_pengiriman']?.toString(),
      );
      if (waktuMakan != null && status != null && status.isNotEmpty) {
        statusPengirimanHariIni[waktuMakan] = status;
      }
    }

    final Map<String, String> mapMenuHariIni = {};
    final normalizedDiet = targetDiet == 'Diet' ? 'Cutting' : targetDiet;
    if (targetDiet != 'Belum ada target' && kitchenIdsToday.isNotEmpty) {
      final menuResponse = await _client
          .from(AppConstants.tableMasterMenuHarian)
          .select('mitra_id, waktu_makan, nama_menu')
          .eq('tanggal', tanggalHariIni)
          .eq('target_diet', normalizedDiet)
          .inFilter('mitra_id', kitchenIdsToday);

      for (var menu in (menuResponse as List<dynamic>)) {
        final key = '${menu['mitra_id']}_${menu['waktu_makan']}';
        mapMenuHariIni[key] = menu['nama_menu']?.toString() ?? '';
      }
    }

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
      final mitraId = mapDapurAlamat[alamatId];
      final namaMenu = mitraId == null
          ? 'Menu Sehat Pilihan Chef'
          : mapMenuHariIni['${mitraId}_$waktuMakan'] ??
                'Menu Sehat Pilihan Chef';

      return ScheduledMealItem(
        waktuMakan: waktuMakan,
        namaMenu: namaMenu,
        namaAlamat: namaAlamat,
        jamKirim: defaultJam[waktuMakan] ?? '12:00',
        statusPengiriman:
            statusPengirimanHariIni[waktuMakan] ?? AppConstants.statusDimasak,
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

  /// Mengambil jadwal pengiriman makan selama satu minggu penuh (Senin s/d Minggu)
  Future<WeeklyScheduleData> fetchWeeklySchedule(String userId) async {
    final now = DateTime.now();
    final todayClean = DateTime(now.year, now.month, now.day);
    final hariIniString = DateFormatter.getTodayIndonesianDayName(now);
    final tanggalHariIni = DateFormatter.toIsoDateString(now);

    // 1. Tentukan tanggal untuk setiap hari di minggu berjalan (Senin - Minggu)
    final monday = DateFormatter.getMondayOfCurrentWeek(now);
    final listHari = AppConstants.listHari;
    final Map<String, String> mapHariKeIso = {};
    final Map<String, String> mapHariKeFormatted = {};
    final Map<String, DateTime> mapHariKeDateTime = {};

    for (int i = 0; i < listHari.length; i++) {
      final dayDate = monday.add(Duration(days: i));
      final dayName = listHari[i];
      mapHariKeDateTime[dayName] = dayDate;
      mapHariKeIso[dayName] = DateFormatter.toIsoDateString(dayDate);
      mapHariKeFormatted[dayName] = DateFormatter.formatIndonesianDate(
        mapHariKeIso[dayName],
      );
    }

    // 2. Cek apakah user memiliki paket aktif
    final packageResponseList = await _client
        .from(AppConstants.tableTransaksiLangganan)
        .select('id, tanggal_selesai')
        .eq('user_id', userId)
        .eq('status_bayar', AppConstants.paymentLunas)
        .gte('tanggal_selesai', tanggalHariIni)
        .order('tanggal_selesai', ascending: false)
        .limit(1);

    final bool adaPaketAktif = packageResponseList.isNotEmpty;

    // 3. Tarik profil user (target diet & target kalori)
    final profileResponse = await _client
        .from(AppConstants.tableUsers)
        .select('target_diet, target_kalori_harian')
        .eq('id', userId)
        .limit(1);

    final Map<String, dynamic>? profileData = profileResponse.isNotEmpty
        ? profileResponse.first
        : null;

    final targetDiet = profileData?['target_diet']?.toString() ?? 'Jaga BB';
    final targetKalori =
        (profileData?['target_kalori_harian'] as num?)?.toInt() ?? 2000;
    final normalizedDiet = targetDiet == 'Diet' ? 'Cutting' : targetDiet;

    // 4. Tarik alamat tersimpan beserta dapur yang melayaninya.
    final addressResponse = await _client
        .from(AppConstants.tableAlamatUser)
        .select('id, label_alamat, mitra_id')
        .eq('user_id', userId);

    final Map<String, String> mapAlamat = {};
    final Map<String, String> mapDapurAlamat = {};
    for (var addr in (addressResponse as List<dynamic>)) {
      final addressId = addr['id'].toString();
      mapAlamat[addressId] =
          addr['label_alamat']?.toString() ?? 'Alamat Tersimpan';
      final kitchenId = addr['mitra_id']?.toString();
      if (kitchenId != null) mapDapurAlamat[addressId] = kitchenId;
    }

    // 5. Tarik menu untuk dapur yang melayani alamat pengguna.
    final mondayIso = mapHariKeIso['Senin']!;
    final sundayIso = mapHariKeIso['Minggu']!;

    final Map<String, Map<String, String>> mapMenuMingguIni = {};
    final kitchenIds = mapDapurAlamat.values.toSet().toList();
    if (targetDiet != 'Belum ada target' && kitchenIds.isNotEmpty) {
      final menuResponse = await _client
          .from(AppConstants.tableMasterMenuHarian)
          .select('mitra_id, tanggal, waktu_makan, nama_menu, deskripsi')
          .gte('tanggal', mondayIso)
          .lte('tanggal', sundayIso)
          .eq('target_diet', normalizedDiet)
          .inFilter('mitra_id', kitchenIds);

      for (var menu in (menuResponse as List<dynamic>)) {
        final tgl = menu['tanggal']?.toString() ?? '';
        final wm = menu['waktu_makan']?.toString() ?? '';
        final mitraId = menu['mitra_id']?.toString() ?? '';
        mapMenuMingguIni['${tgl}_${mitraId}_$wm'] = {
          'nama': menu['nama_menu']?.toString() ?? '',
          'deskripsi': menu['deskripsi']?.toString() ?? '',
        };
      }
    }

    // 6. Tarik log status pengiriman dari menu_harian untuk user ini minggu ini
    final logResponse = await _client
        .from(AppConstants.tableMenuHarian)
        .select('tanggal, waktu_makan, status_pengiriman')
        .eq('user_id', userId)
        .gte('tanggal', mondayIso)
        .lte('tanggal', sundayIso);

    final Map<String, String> mapStatusLog = {};
    for (var log in (logResponse as List<dynamic>)) {
      final tgl = log['tanggal']?.toString() ?? '';
      final wm = log['waktu_makan']?.toString() ?? '';
      mapStatusLog["${tgl}_$wm"] = _statusUntukTampilan(
        log['status_pengiriman']?.toString(),
      );
    }

    // 7. Tarik seluruh jadwal pengiriman mingguan user (7 hari x 3 waktu makan)
    final scheduleResponse = await _client
        .from(AppConstants.tableJadwalPengiriman)
        .select()
        .eq('user_id', userId);

    final orderUrutanWaktu = {
      AppConstants.mealSarapan: 1,
      AppConstants.mealSiang: 2,
      AppConstants.mealMalam: 3,
    };

    final defaultJam = {
      AppConstants.mealSarapan: '07:00 - 08:00',
      AppConstants.mealSiang: '11:30 - 12:30',
      AppConstants.mealMalam: '18:00 - 19:00',
    };

    // Proporsi kalori per waktu makan
    final kaloriPerWaktu = {
      AppConstants.mealSarapan: (targetKalori * 0.30).round(),
      AppConstants.mealSiang: (targetKalori * 0.45).round(),
      AppConstants.mealMalam: (targetKalori * 0.25).round(),
    };

    final rawList = List<Map<String, dynamic>>.from(scheduleResponse);
    final Map<String, List<ScheduledMealItem>> jadwalPerHari = {};

    for (var day in listHari) {
      final dayDate = mapHariKeDateTime[day]!;
      final dayIso = mapHariKeIso[day]!;
      final isPast = dayDate.isBefore(todayClean);
      final isToday = dayDate.isAtSameMomentAs(todayClean);

      final itemsForDay = rawList.where((j) => j['hari'] == day).toList();
      itemsForDay.sort((a, b) {
        final orderA = orderUrutanWaktu[a['waktu_makan']] ?? 99;
        final orderB = orderUrutanWaktu[b['waktu_makan']] ?? 99;
        return orderA.compareTo(orderB);
      });

      jadwalPerHari[day] = itemsForDay.map((j) {
        final waktuMakan = j['waktu_makan']?.toString() ?? '';
        final alamatId = j['alamat_id']?.toString() ?? '';
        final namaAlamat = mapAlamat[alamatId] ?? 'Alamat Tersimpan';
        final mitraId = mapDapurAlamat[alamatId] ?? '';

        final menuKey = '${dayIso}_${mitraId}_$waktuMakan';
        final menuInfo = mapMenuMingguIni[menuKey];
        final statusKey = '${dayIso}_$waktuMakan';

        // Nama menu: jika dapur sudah isi, pakai menu dapur.
        // Jika belum, gunakan placeholder informatif sesuai program diet.
        final String namaMenu;
        final String? deskripsi;
        if (menuInfo != null && menuInfo['nama']!.isNotEmpty) {
          namaMenu = menuInfo['nama']!;
          deskripsi = menuInfo['deskripsi'];
        } else {
          if (isToday) {
            namaMenu = 'Menu Sehat Pilihan Chef ($targetDiet)';
            deskripsi = 'Disiapkan segar oleh dapur mitra';
          } else if (isPast) {
            namaMenu = 'Menu Spesial NutriBox ($targetDiet)';
            deskripsi = null;
          } else {
            namaMenu = 'Menu Sedang Disiapkan Chef ($targetDiet)';
            deskripsi = 'Diumumkan oleh dapur pada H-1';
          }
        }

        // Status Pengiriman
        String statusPengiriman;
        if (mapStatusLog.containsKey(statusKey) &&
            mapStatusLog[statusKey]!.isNotEmpty) {
          statusPengiriman = mapStatusLog[statusKey]!;
        } else if (isPast) {
          statusPengiriman = AppConstants.statusTerkirim;
        } else if (isToday) {
          statusPengiriman = 'Dimasak';
        } else {
          statusPengiriman = 'Terjadwal';
        }

        return ScheduledMealItem(
          waktuMakan: waktuMakan,
          namaMenu: namaMenu,
          namaAlamat: namaAlamat,
          jamKirim: defaultJam[waktuMakan] ?? '12:00',
          statusPengiriman: statusPengiriman,
          kalori: kaloriPerWaktu[waktuMakan],
          deskripsi: deskripsi,
        );
      }).toList();
    }

    return WeeklyScheduleData(
      adaPaketAktif: adaPaketAktif,
      targetDiet: targetDiet,
      targetKalori: targetKalori,
      hariIni: hariIniString,
      jadwalPerHari: jadwalPerHari,
      tanggalFormattedPerHari: mapHariKeFormatted,
      tanggalIsoPerHari: mapHariKeIso,
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

/// FutureProvider untuk memuat jadwal pengiriman mingguan pelanggan
final weeklyScheduleProvider = FutureProvider<WeeklyScheduleData>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User belum terautentikasi');
  }
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchWeeklySchedule(user.id);
});
