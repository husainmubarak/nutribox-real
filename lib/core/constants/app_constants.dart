class AppConstants {
  AppConstants._();

  // Supabase Configuration
  static const String supabaseUrl = 'https://hqdihfmxygxzqmxgfgsr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxZGloZm14eWd4enFteGdmZ3NyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgzNTkxMDMsImV4cCI6MjEwMzkzNTEwM30.v_UM8zlpQj1LGpsE9AJSDJgpRIXVwLxv3zgwIlrXLBI';

  // Table Names
  static const String tableUsers = 'users';
  static const String tableMitraDapur = 'mitra_dapur';
  static const String tablePaketLangganan = 'paket_langganan';
  static const String tableAlamatUser = 'alamat_user';
  static const String tableJadwalPengiriman = 'jadwal_pengiriman';
  static const String tableTransaksiLangganan = 'transaksi_langganan';
  static const String tableMasterMenuHarian = 'master_menu_harian';
  static const String tableMenuHarian = 'menu_harian';

  // Diet Options
  static const String dietBulking = 'Bulking';
  static const String dietCutting = 'Cutting';
  static const String dietJagaBB = 'Jaga BB';

  static const List<String> listPilihanDiet = [
    dietBulking,
    dietCutting,
    dietJagaBB,
  ];

  // Meal Times
  static const String mealSarapan = 'Sarapan';
  static const String mealSiang = 'Siang';
  static const String mealMalam = 'Malam';

  static const List<String> listWaktuMakan = [
    mealSarapan,
    mealSiang,
    mealMalam,
  ];

  // Days of Week
  static const List<String> listHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  // Payment Statuses
  static const String paymentMenunggu = 'Menunggu Konfirmasi';
  static const String paymentLunas = 'Lunas';

  // Delivery Statuses
  static const String statusDimasak = 'Dimasak';
  static const String statusDikirim = 'Dikirim';
}
