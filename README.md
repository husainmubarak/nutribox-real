# NutriBox

NutriBox adalah aplikasi mobile Flutter untuk mengelola langganan katering sehat, jadwal pengiriman makanan, serta operasi mitra dapur. Aplikasi memiliki dua jenis akun: **user/pelanggan** dan **mitra dapur**. Data autentikasi dan operasional tersimpan di Supabase.

## Fitur

### User

- Registrasi, login, dan pengisian profil gizi.
- Perhitungan kebutuhan kalori dan pilihan target diet: Bulking, Cutting, atau Jaga BB.
- Pemilihan paket langganan dan pengaturan jadwal makan.
- Penyimpanan beberapa alamat dan titik lokasi melalui peta atau GPS.
- Penautan alamat ke dapur yang koordinatnya paling dekat berdasarkan jarak garis lurus.
- Beranda dengan ringkasan langganan dan pengiriman hari ini, jadwal mingguan, riwayat, dan informasi akun.

### Mitra dapur

- Dasbor jumlah porsi dan ringkasan kebutuhan berdasarkan program diet.
- Input menu berdasarkan tanggal, program diet, waktu makan, nama menu, serta deskripsi opsional.
- Manifest pengiriman pelanggan yang terhubung ke dapur.
- Pembaruan status kiriman menjadi **Terkirim**.

## Teknologi

- Flutter dan Dart.
- Riverpod untuk state management.
- Supabase Auth dan PostgreSQL untuk autentikasi dan penyimpanan data.
- `flutter_map` dengan tile OpenStreetMap untuk pemilih lokasi.
- `geolocator` untuk memperoleh lokasi perangkat saat pengguna memberikan izin.

## Menjalankan aplikasi

1. Pasang Flutter SDK yang memenuhi batas versi pada `pubspec.yaml` dan siapkan Android Studio/emulator atau perangkat Android.
2. Pastikan konfigurasi URL dan publishable key Supabase di `lib/core/constants/app_constants.dart` menunjuk ke proyek yang berisi skema serta data NutriBox.
3. Dari root proyek, jalankan:

   ```bash
   flutter pub get
   flutter run
   ```

4. Untuk menjalankan pada emulator tertentu:

   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

Konfigurasi Supabase saat ini berada di `AppConstants`. Publishable/anon key boleh digunakan di aplikasi klien dengan kebijakan RLS yang benar; jangan pernah menaruh `service_role` key atau rahasia server di aplikasi atau repositori.

## Data demo dan panduan

- Daftar akun demo: [Kredensial_Akun_Demo_NutriBox.md](Kredensial_Akun_Demo_NutriBox.md).
- Panduan penggunaan dari sisi pelanggan dan mitra dapur: [Panduan_Penggunaan_NutriBox.md](Panduan_Penggunaan_NutriBox.md).
- Akun dan beberapa profil berisi data sintetis untuk demonstrasi. Paket, transaksi, pembayaran, koordinat dapur, dan menu perlu ditinjau sebelum dipakai untuk operasional nyata.

## Catatan integrasi peta dan langganan

- Penentuan dapur menggunakan koordinat alamat user dan koordinat dapur. Perhitungan saat ini berupa jarak garis lurus, bukan estimasi jarak atau waktu perjalanan melalui jalan.
- Jika tidak ada dapur yang memiliki koordinat, penyimpanan alamat gagal. Perbarui koordinat dapur ke titik operasional yang tepat.
- Pemilih peta menggunakan server tile standar OpenStreetMap; atribusi ditampilkan di aplikasi. Ikuti kebijakan penggunaan tile OpenStreetMap dan gunakan penyedia tile yang sesuai untuk trafik produksi.
- Alur pembayaran saat ini adalah simulasi aplikasi. Memilih GoPay, Transfer Bank, atau QRIS belum memproses pembayaran sungguhan.

## Struktur kode ringkas

```text
lib/
  core/          konstanta, tema, layanan, dan widget bersama
  features/
    auth/        login, registrasi, dan penentuan jenis akun
    home/        beranda, jadwal, serta riwayat user
    kitchen/     dasbor dapur, input menu, dan manifest
    profile/     profil fisik dan kalkulator gizi
    subscription/ paket, alamat/lokasi, jadwal, serta pembayaran demo
supabase/
  migrations/    migrasi skema dan perubahan database
```

## Status proyek

Proyek ini merupakan aplikasi demonstrasi/akademik. Validasi operasional, kebijakan keamanan Supabase, data menu dan paket, kapasitas dapur, layanan geocoding/rute, serta integrasi pembayaran perlu disiapkan sebelum digunakan secara komersial.
