import 'package:flutter_test/flutter_test.dart';
import 'package:nutribox/features/kitchen/models/daily_menu_model.dart';
import 'package:nutribox/features/kitchen/models/delivery_manifest_item.dart';
import 'package:nutribox/features/kitchen/models/kitchen_dashboard_data.dart';
import 'package:nutribox/features/profile/models/user_profile.dart';
import 'package:nutribox/features/subscription/models/address_model.dart';
import 'package:nutribox/features/subscription/models/package_model.dart';
import 'package:nutribox/features/subscription/models/schedule_model.dart';

void main() {
  group('Model Serialization Tests', () {
    test('PackageModel serialization and deserialization', () {
      final map = {
        'id': 1,
        'nama_paket': 'Paket Bulanan Sehat',
        'durasi_hari': 30,
        'harga': 1500000,
      };

      final package = PackageModel.fromMap(map);
      expect(package.id, 1);
      expect(package.namaPaket, 'Paket Bulanan Sehat');
      expect(package.durasiHari, 30);
      expect(package.harga, 1500000);

      final toMap = package.toMap();
      expect(toMap['nama_paket'], 'Paket Bulanan Sehat');
      expect(toMap['harga'], 1500000);
    });

    test('AddressModel serialization and null-aware handling', () {
      final mapWithMitra = {
        'id': 'addr-1',
        'user_id': 'user-1',
        'label_alamat': 'Kantor',
        'alamat_lengkap': 'Jl. Sudirman No. 10',
        'mitra_id': 'kitchen-1',
      };

      final address = AddressModel.fromMap(mapWithMitra);
      expect(address.id, 'addr-1');
      expect(address.labelAlamat, 'Kantor');
      expect(address.mitraId, 'kitchen-1');
      expect(address.toMap()['mitra_id'], 'kitchen-1');

      final mapWithoutMitra = {
        'id': 'addr-2',
        'user_id': 'user-1',
        'label_alamat': 'Rumah',
        'alamat_lengkap': 'Jl. Melati No. 5',
      };
      final address2 = AddressModel.fromMap(mapWithoutMitra);
      expect(address2.mitraId, isNull);
      expect(address2.toMap().containsKey('mitra_id'), isFalse);
    });

    test('ScheduleItem serialization', () {
      final item = ScheduleItem(
        userId: 'user-123',
        hari: 'Senin',
        waktuMakan: 'Sarapan',
        alamatId: 'addr-1',
      );

      final map = item.toMap();
      expect(map['user_id'], 'user-123');
      expect(map['hari'], 'Senin');
      expect(map['waktu_makan'], 'Sarapan');
      expect(map['alamat_id'], 'addr-1');

      final deserialized = ScheduleItem.fromMap(map);
      expect(deserialized.hari, 'Senin');
      expect(deserialized.waktuMakan, 'Sarapan');
    });

    test('UserProfile model toMap and fromMap', () {
      final profile = UserProfile(
        id: 'usr-1',
        namaLengkap: 'Husain',
        gender: 'L',
        tanggalLahir: '2004-01-01',
        tinggiBadan: 175,
        beratBadan: 70,
        targetDiet: 'Bulking',
        tingkatAktivitas: '1.2',
        statusBmi: 'Ideal',
        targetKaloriHarian: 2400,
      );

      final map = profile.toMap();
      expect(map['nama_lengkap'], 'Husain');
      expect(map['target_diet'], 'Bulking');
      expect(map['target_kalori_harian'], 2400);

      final fromMap = UserProfile.fromMap(map);
      expect(fromMap.id, 'usr-1');
      expect(fromMap.namaLengkap, 'Husain');
      expect(fromMap.tinggiBadan, 175);
    });

    test('DailyMenuModel serialization', () {
      final menu = DailyMenuModel(
        tanggal: '2026-09-29',
        targetDiet: 'Cutting',
        waktuMakan: 'Siang',
        namaMenu: 'Dada Ayam Panggang & Salad',
        deskripsi: 'Tinggi protein rendah lemak',
      );

      final map = menu.toMap();
      expect(map['nama_menu'], 'Dada Ayam Panggang & Salad');
      expect(map['target_diet'], 'Cutting');

      final fromMap = DailyMenuModel.fromMap(map);
      expect(fromMap.namaMenu, 'Dada Ayam Panggang & Salad');
      expect(fromMap.waktuMakan, 'Siang');
    });

    test('DeliveryManifestItem and KitchenDashboardData instantiation', () {
      final item = DeliveryManifestItem(
        userId: 'u1',
        alamatId: 'a1',
        namaUser: 'Budi',
        targetDiet: 'Bulking',
        waktuMakan: 'Sarapan',
        labelAlamat: 'Rumah',
        alamatLengkap: 'Jl. Mawar',
        statusPengiriman: 'Dimasak',
      );

      expect(item.namaUser, 'Budi');
      expect(item.statusPengiriman, 'Dimasak');

      final dashboard = KitchenDashboardData(
        namaDapur: 'Dapur Sehat Pusat',
        hariIni: 'Selasa',
        totalPorsi: 12,
        rekapPesanan: {'Bulking': 7, 'Cutting': 5},
      );

      expect(dashboard.namaDapur, 'Dapur Sehat Pusat');
      expect(dashboard.totalPorsi, 12);
      expect(dashboard.rekapPesanan['Bulking'], 7);
    });
  });
}
