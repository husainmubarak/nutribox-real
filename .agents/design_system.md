# DESIGN_SYSTEM.md — Aplikasi Catering Sehat (Gaya Gojek) untuk Flutter

> **ATURAN UTAMA UNTUK AGEN AI**
> Dokumen ini adalah sumber kebenaran tunggal untuk seluruh tampilan aplikasi.
> Aplikasi ini adalah **aplikasi catering online berlangganan**, tetapi bahasa visualnya
> **WAJIB** meniru aplikasi Gojek (Home, menu "Top services", kartu saldo, grid layanan,
> bottom sheet, opsi terpilih berlatar hijau pastel, CTA pill hijau).
> Jika ada konflik antara kebiasaan default Material/Flutter dan dokumen ini,
> **dokumen ini selalu menang**.
> DILARANG membuat gaya sendiri, mengganti palet warna, atau menambah komponen
> yang tidak ada di dokumen ini tanpa persetujuan eksplisit dari pengguna.

---

## 0. Cara Kerja Agen (Wajib Diikuti)

1. Sebelum menulis UI, baca seluruh dokumen ini.
2. Semua warna, spasi, radius, dan tipografi **harus** diambil dari token di Bagian 2–3. Dilarang hardcode `Color(0xFF...)`, angka spasi, atau `TextStyle` langsung di dalam layar.
3. Gunakan komponen reusable di Bagian 6. Jika komponen belum ada, buat di `lib/core/widgets/` sesuai spesifikasi, lalu pakai ulang. Satu komponen = satu file.
4. Pecah layar menjadi widget kecil. Dilarang satu file layar raksasa.
5. Setelah selesai, jalankan **Checklist Kepatuhan** (Bagian 10) dan laporkan hasilnya.
6. Bahasa UI default: **Bahasa Indonesia** (Bagian 9).
7. Jika spesifikasi untuk suatu layar tidak ada, turunkan dari pola terdekat di dokumen ini dan **sebutkan asumsi** yang dipakai, jangan mengarang gaya baru.

---

## 1. Prinsip Visual

- **Bersih, terang, ramah**: latar abu sangat muda, kartu putih, sudut membulat.
- **Satu warna merek dominan (hijau)** untuk header, CTA utama, dan state aktif.
- **Ikon fitur berwarna pastel** di dalam kotak rounded, bukan ikon polos.
- **Hierarki jelas**: judul bold, subjudul abu, angka penting (kalori, harga, sisa hari) bold.
- **Satu CTA utama per layar**, berbentuk pill hijau besar di bawah.
- **Padat tapi lega**: konten dikelompokkan dalam kartu dan grid, spasi kelipatan 4.
- **Gradien hijau halus** hanya untuk header, kartu ringkasan utama, dan CTA.

---

## 2. Design Tokens

### 2.1 Warna

| Token | Hex | Penggunaan |
|---|---|---|
| `brandGreen` | `#00AA13` | Header, CTA utama, nav/tab aktif, ikon aktif |
| `brandGreenLight` | `#4CCB5A` | Ujung gradien hijau |
| `brandGreenDark` | `#008A0F` | Pressed state, status bar overlay |
| `brandGreenSoft` | `#E3F6E5` | Latar pastel ikon hijau, baris/kartu terpilih |
| `walletTeal` | `#0F7C99` | Aksen kartu ringkasan (opsional, varian kartu langganan) |
| `accentRed` | `#EE2737` | Badge notifikasi, aksen peringatan |
| `accentRedSoft` | `#FDE4E6` | Latar pastel ikon merah |
| `accentBlue` | `#1B8AD3` | Info, banner voucher, ikon bantuan |
| `accentBlueSoft` | `#DCEFFB` | Latar pastel ikon biru, banner info |
| `accentPurple` | `#7A3FA3` | Aksen Makan Malam, ikon promo/klub |
| `accentPurpleSoft` | `#EFE3F7` | Latar pastel ungu |
| `accentOrange` | `#F26B21` | Aksen status berlebih, peringatan ringan |
| `accentOrangeSoft` | `#FFE9DC` | Latar pastel oranye |
| `accentYellow` | `#FFB020` | Aksen Sarapan |
| `accentYellowSoft` | `#FFF1D6` | Latar pastel kuning |
| `textPrimary` | `#1C1C1C` | Judul, harga, angka penting |
| `textSecondary` | `#6B6B6B` | Subjudul, deskripsi, label nonaktif |
| `divider` | `#E8E8E8` | Garis pemisah list, border outline |
| `surface` | `#FFFFFF` | Kartu, bottom sheet, bottom nav |
| `background` | `#F4F5F7` | Latar halaman di belakang kartu |

**Pemetaan semantik (wajib pakai alias ini di UI, bukan warna mentah):**

| Alias | Warna | Dipakai untuk |
|---|---|---|
| `mealBreakfast` | `accentYellow` / `accentYellowSoft` | Sarapan |
| `mealLunch` | `brandGreen` / `brandGreenSoft` | Makan Siang |
| `mealDinner` | `accentPurple` / `accentPurpleSoft` | Makan Malam |
| `statusUnder` | `accentBlue` / `accentBlueSoft` | Status berat: kurang |
| `statusIdeal` | `brandGreen` / `brandGreenSoft` | Status berat: ideal |
| `statusOver` | `accentOrange` / `accentOrangeSoft` | Status berat: berlebih |
| `deliveryCooking` | `accentYellow` / `accentYellowSoft` | Status: Dimasak |
| `deliveryOnTheWay` | `accentBlue` / `accentBlueSoft` | Status: Dalam perjalanan |
| `deliveryDone` | `brandGreen` / `brandGreenSoft` | Status: Terkirim |

### 2.2 Gradien

- `brandGradient`: `LinearGradient(begin: topLeft, end: bottomRight, colors: [brandGreen, brandGreenLight])`.
- Boleh dipakai di: header Home, `CalorieSummaryCard`, `SubscriptionCard`, `AppPrimaryButton`.
- Dilarang: gradien multi-warna mencolok, gradien pada teks, gradien di kartu biasa.

### 2.3 Spasi (kelipatan 4)

`xs=4, sm=8, md=12, lg=16, xl=20, xxl=24, xxxl=32`
Padding horizontal halaman standar: **16**.

### 2.4 Radius

| Token | Nilai | Penggunaan |
|---|---|---|
| `sm` | 8 | Badge kecil, info banner |
| `md` | 12 | Kartu kategori, kotak ikon, input, gambar menu |
| `lg` | 16 | Kartu besar (ringkasan, paket, promo) |
| `sheet` | 20 | Sudut atas bottom sheet, sudut bawah gambar detail |
| `pill` | 999 | Search bar, tombol CTA, chip, badge status |

### 2.5 Elevasi / Bayangan

- Kartu: `BoxShadow(color: black 8% opacity, blurRadius: 12, offset: (0, 4))`
- Bottom sheet & bottom nav: bayangan ke atas, `offset: (0, -2)`, blur 12, opacity 8%
- Dilarang memakai elevasi Material default yang tebal.

### 2.6 Tipografi

Font: **Plus Jakarta Sans** (atau Inter), daftarkan di `pubspec.yaml`. Fallback: Roboto.

| Style | Size / Weight | Penggunaan |
|---|---|---|
| `titleLg` | 20 / 700 | Judul halaman/section besar |
| `titleMd` | 16 / 700 | Judul section, nama item |
| `bodyMd` | 14 / 500 | Teks isi, input |
| `bodySm` | 12 / 400 | Subjudul, jam kirim, deskripsi |
| `label` | 12 / 500 | Label di bawah ikon fitur, chip |
| `price` | 16 / 700 | Harga |
| `metric` | 28 / 800 | Angka besar (kalori harian, sisa hari) |
| `cta` | 16 / 700 | Teks tombol utama |

---

## 3. Setup Tema Flutter

Buat `lib/core/theme/app_tokens.dart` dan `app_theme.dart`.

```dart
import 'package:flutter/material.dart';

class AppColors {
  static const brandGreen = Color(0xFF00AA13);
  static const brandGreenLight = Color(0xFF4CCB5A);
  static const brandGreenDark = Color(0xFF008A0F);
  static const brandGreenSoft = Color(0xFFE3F6E5);
  static const walletTeal = Color(0xFF0F7C99);
  static const accentRed = Color(0xFFEE2737);
  static const accentRedSoft = Color(0xFFFDE4E6);
  static const accentBlue = Color(0xFF1B8AD3);
  static const accentBlueSoft = Color(0xFFDCEFFB);
  static const accentPurple = Color(0xFF7A3FA3);
  static const accentPurpleSoft = Color(0xFFEFE3F7);
  static const accentOrange = Color(0xFFF26B21);
  static const accentOrangeSoft = Color(0xFFFFE9DC);
  static const accentYellow = Color(0xFFFFB020);
  static const accentYellowSoft = Color(0xFFFFF1D6);
  static const textPrimary = Color(0xFF1C1C1C);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider = Color(0xFFE8E8E8);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF4F5F7);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandGreen, brandGreenLight],
  );
}

class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 20.0, xxl = 24.0, xxxl = 32.0;
}

class AppRadius {
  static const sm = 8.0, md = 12.0, lg = 16.0, sheet = 20.0, pill = 999.0;
}

class AppShadows {
  static final card = [
    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static final top = [
    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2)),
  ];
}
```

`ThemeData` wajib: `useMaterial3: true`, `colorScheme.primary = brandGreen`,
`scaffoldBackgroundColor = background`, `fontFamily` sesuai Bagian 2.6,
`bottomNavigationBarTheme` (selected = brandGreen, unselected = textSecondary, label selalu tampil),
`dividerTheme.color = divider`, `appBarTheme` tanpa elevasi dan latar transparan/putih,
`inputDecorationTheme` (rounded 12, fill putih, border `divider`, fokus `brandGreen`).

---

## 4. Layout & Navigasi

- **Bottom navigation** (putih, bayangan atas, ikon outline + label 11–12sp):
  `Beranda | Jadwal | Riwayat | Akun`. Badge merah boleh di item `Jadwal`.
  - Aktif: ikon & label `brandGreen`. Nonaktif: `textSecondary`.
- **Safe area** wajib dihormati. Jarak konten ke bottom nav minimal 16.
- Scroll vertikal untuk konten; carousel horizontal untuk promo.
- **Bottom sheet**: drag handle (bar abu 40×4, radius pill, tengah atas), sudut atas radius 20, padding 16.
- Halaman alur (onboarding, paket, alamat, bayar) **tanpa bottom nav**, memakai `AppBar` transparan dengan tombol back bulat putih.

---

## 5. Spesifikasi Layar (Wajib Ditiru)

### 5.1 Onboarding Biodata & Hasil

- Form bertahap dengan `StepperHeader` (progres hijau) di atas latar `background`; field dalam kartu putih radius 16.
- Input: nama, gender (chip pilihan), tanggal lahir (date picker), berat, tinggi. Field rounded 12, label di atas.
- CTA `Lanjut` = `AppPrimaryButton`, satu per layar.
- **Halaman Hasil**: `CalorieSummaryCard` (gradien hijau) berisi **status berat badan** (badge sesuai `statusUnder/Ideal/Over`) dan **kebutuhan kalori harian** (`metric`, satuan `kkal/hari`).
  CTA `Lihat Paket Langganan` dan tautan teks `Lewati dulu`.

### 5.2 Pilih Paket Langganan

- Judul `titleLg`, subjudul abu.
- Daftar `PackageCard` (1 / 3 / 6 bulan): kartu putih radius 16, bayangan tipis, nama paket bold, harga bold + harga per hari abu kecil, badge pill pastel (`Hemat X%`, `Paling Populer`).
- Kartu terpilih: latar `brandGreenSoft` + border `brandGreen` 1.5.
- CTA bawah varian `withPrice`: `Lanjut ke Alamat` + total harga di kanan.

### 5.3 Input Alamat per Hari & Waktu Makan

- `WeekDayChips` horizontal (aktif = hijau solid).
- Per hari, 3 `MealAddressTile` (Sarapan, Makan Siang, Makan Malam): ikon pastel sesuai warna meal, alamat terpilih, tombol `Ubah`.
- Pilih/ubah alamat lewat **bottom sheet** berisi daftar alamat tersimpan (`OptionTile`, terpilih = `brandGreenSoft`) dan tombol `Tambah alamat baru`.
- Toggle/chip `Samakan semua hari` di atas daftar.
- Alamat dapat diubah selama langganan aktif (tampilkan juga dari Dashboard, aksi `Alamat`).

### 5.4 Pembayaran

- Ringkasan pesanan dalam kartu putih (paket, durasi, tanggal mulai, total).
- Daftar metode bayar sebagai `OptionTile` (ikon + nama, terpilih = `brandGreenSoft`).
- `InfoBanner` untuk voucher/promo dengan tombol pill kecil `Pakai`.
- CTA `Bayar` varian `withPrice`.

### 5.5 Dashboard (Beranda) — mengadopsi Home Gojek

Urutan dari atas ke bawah:

1. **Header gradien hijau**: sapaan (`Halo, <nama>`) putih, avatar bulat kanan (ikon orang putih, badge merah bila ada notifikasi), lalu `AppSearchBar` read-only (`Cari menu atau paket`).
2. **Kartu ringkasan** (gaya kartu saldo Gojek, radius 16, overlap ke header):
   - *Tanpa langganan*: status berat (badge) + kebutuhan kalori + tombol pill kecil `Berlangganan`.
   - *Dengan langganan* (`SubscriptionCard`): kiri = **sisa hari** (`metric`) + progres bar tipis; kanan = 3 aksi (`Jadwal`, `Alamat`, `Bantuan`), masing-masing ikon putih dalam kotak rounded outline + label putih 12sp.
3. **Jadwal Hari Ini** (`titleMd`), hanya bila langganan aktif: 3 `MealScheduleCard` (Sarapan, Siang, Malam). Tap → Detail Menu (5.6).
4. **Grid layanan 4 kolom** (pintasan fitur), contoh: `Jadwal`, `Alamat`, `Paket`, `Riwayat`, `Nutrisi`, `Bantuan`, `Promo`, `Lainnya`. Ikon di kotak pastel 56×56, label 1 baris.
5. **Banner promo/edukasi** (`PromoCarousel` + indikator titik).
6. Section `Tips sehat buat kamu` + `AppChip` filter horizontal (aktif hijau solid) + kartu konten bergambar radius 16.

### 5.6 Detail Menu

- Gambar besar di atas (sudut bawah radius 20), tombol back bulat putih.
- Nama menu `titleLg`, badge waktu makan (warna meal), kalori besar.
- `NutritionSummary`: 4 kolom (Kalori, Protein, Karbo, Lemak), ikon pastel + angka bold.
- Daftar komposisi memakai `OptionTile` tanpa harga.
- Halaman informasi: **tanpa CTA utama**.

### 5.7 Jadwal & Riwayat

- `WeekDayChips` + daftar `MealScheduleCard` untuk hari terpilih.
- Riwayat: daftar kartu dengan status akhir dan `Divider` antar baris.
- Empty state: ilustrasi sederhana + `titleMd` + 1 tombol (`Lihat Paket`).

### 5.8 Menu "Semua Layanan" (Bottom Sheet, opsional)

- Dibuka dari item `Lainnya` pada grid. Drag handle, judul `Semua layanan` (`titleLg`).
- Grid 4 kolom + toggle grid/list (segmented kecil abu di kanan).
- Mode list: header grup abu kecil, baris = kotak ikon pastel 40×40 radius 12 + judul bold + subjudul abu, dipisah `Divider` (indent mulai dari teks).

### 5.9 Akun

- Kartu profil di atas (avatar, nama, ringkasan status berat/kalori).
- Daftar menu bergaya list Gojek (ikon pastel 40×40 + judul + chevron, `Divider` tipis): Biodata, Paket Saya, Alamat Tersimpan, Metode Pembayaran, Bantuan, Keluar.
- `Keluar` memakai teks `accentRed`, tanpa tombol besar.

---

## 6. Komponen Reusable (Wajib Dibuat & Dipakai)

Lokasi: `lib/core/widgets/`. Satu komponen = satu file.

### 6.1 Komponen Dasar

| Komponen | Spesifikasi |
|---|---|
| `AppPrimaryButton` | Tinggi 52, radius pill, `brandGreen` (boleh `brandGradient`), teks `cta` putih. Varian: `default`, `withPrice` (teks + subteks kiri, harga + ikon panah dalam lingkaran putih kanan), `loading`, `disabled` (abu). Dilarang `ElevatedButton` default tanpa style ini. |
| `AppSearchBar` | Pill putih, tinggi 44, ikon kiri, placeholder `textSecondary`, tanpa border, bayangan tipis. Bisa read-only. |
| `AppChip` | Pill, tinggi 32, aktif = hijau solid teks putih, nonaktif = outline `divider` teks `textPrimary`. |
| `AppBottomSheet` | Drag handle, radius atas 20, latar putih, padding 16. |
| `AppBottomNav` | Wrapper `BottomNavigationBar` sesuai tema, mendukung badge. |
| `OptionTile` | Leading ikon/gambar, judul bold, subjudul abu, trailing opsional. Prop `selected` → latar `brandGreenSoft`. |
| `InfoBanner` | Latar `accentBlueSoft`, radius 8, teks 12sp, tombol pill kecil biru di kanan. |
| `StatusBadge` | Pill kecil pastel dengan teks 11–12sp bold; prop `tone` memakai alias semantik Bagian 2.1. |

### 6.2 Komponen Gojek-Style

| Komponen | Spesifikasi |
|---|---|
| `ServiceGridItem` | Props: `icon`, `label`, `tone` (`green\|red\|blue\|purple\|yellow\|neutral`), `onTap`, `badge?`. Kotak ikon 56×56 radius 12, label 1 baris ellipsis. |
| `ServiceGrid` | 4 kolom, `crossAxisSpacing 8`, `mainAxisSpacing 16`, non-scrollable di dalam halaman. |
| `PromoCarousel` | Radius 16, rasio ±16:7, `PageView` + indikator titik (tinggi 6). |

### 6.3 Komponen Domain Catering

| Komponen | Spesifikasi |
|---|---|
| `CalorieSummaryCard` | Gradien hijau, radius 16, padding 16: badge status berat + `metric` kalori harian + `kkal/hari`. |
| `SubscriptionCard` | Gradien hijau/`walletTeal`, radius 16: sisa hari (`metric`) + progres tipis + 3 aksi cepat. |
| `PackageCard` | Kartu paket, prop `selected`, badge hemat/populer, harga + harga per hari. |
| `MealScheduleCard` | Gambar menu (radius 12), nama menu bold, jam kirim + alamat singkat (`bodySm` abu), `StatusBadge`, aksen warna sesuai waktu makan. |
| `MealAddressTile` | Ikon pastel waktu makan, alamat, tombol `Ubah`. |
| `NutritionSummary` | 4 kolom makro/kalori, ikon pastel + angka bold + label kecil. |
| `WeekDayChips` | Chip hari horizontal (Sen–Min), aktif hijau solid. |
| `StepperHeader` | Indikator langkah onboarding/checkout, progres hijau. |

---

## 7. Interaksi & Animasi

- Tap feedback: `InkWell` ripple lembut atau scale 0.97 selama 100ms.
- Transisi halaman: slide horizontal standar. Bottom sheet: slide up 250ms `easeOutCubic`.
- Skeleton/shimmer abu muda saat memuat; **dilarang** spinner tunggal di tengah layar kecuali di dalam tombol.
- State kosong: ilustrasi sederhana + `titleMd` + 1 tombol aksi.
- Haptic ringan (`selectionClick`) saat memilih paket, alamat, atau metode bayar.
- Error: snackbar floating radius 12 dengan latar `textPrimary`, bukan dialog merah besar.

---

## 8. Role Non-User (jika tampil di aplikasi mobile ini)

Role seperti mitra dapur, ahli gizi, dan kurir **memakai token, komponen, dan bottom sheet yang sama**. Turunkan layarnya dari pola berikut, jangan membuat gaya baru:

| Kebutuhan | Pola yang dipakai |
|---|---|
| Daftar tugas (menu perlu diverifikasi, pengiriman hari ini) | Daftar kartu putih radius 16 + `StatusBadge`, seperti `MealScheduleCard` |
| Form input menu / verifikasi | Form dalam kartu putih (gaya 5.1), CTA pill hijau tunggal |
| Ringkasan harian (jumlah porsi, jumlah pengiriman) | Kartu gradien hijau gaya `SubscriptionCard` + grid pintasan 4 kolom |
| Pilihan status/aksi cepat | `OptionTile` terpilih `brandGreenSoft` di bottom sheet |

Bottom nav tiap role tetap bergaya Bagian 4 dengan item sesuai kebutuhan role tersebut. Admin web berada di repo terpisah dan tidak tercakup dokumen ini.

---

## 9. Bahasa & Konten (Copywriting)

- UI default **Bahasa Indonesia**, nada ramah, singkat, memotivasi, tidak menghakimi.
- Label umum: `Beranda`, `Jadwal`, `Riwayat`, `Akun`, `Lainnya`, `Lanjut`, `Bayar`, `Ubah`.
- Istilah domain: `Paket Langganan`, `Sarapan`, `Makan Siang`, `Makan Malam`, `Kebutuhan kalori`, `Status berat badan`, `Sisa hari`, `Jadwal hari ini`, `Ubah alamat`.
- Status berat badan: gunakan `Kurang`, `Ideal`, `Berlebih`. Hindari kata yang menghakimi seperti "gemuk" atau "kurus".
- Format mata uang: `Rp12.000` (tanpa spasi, titik pemisah ribuan) memakai `intl`.
- Kalori `1.850 kkal`, berat `65 kg`, tinggi `170 cm`.
- Status pengiriman: `Dimasak`, `Dalam perjalanan`, `Terkirim`.

---

## 10. Checklist Kepatuhan (Agen Wajib Verifikasi)

Sebelum menyatakan tugas selesai, pastikan semuanya benar:

- [ ] Tidak ada `Color(0xFF...)`, angka spasi, atau `TextStyle` hardcode di file layar.
- [ ] Dashboard: header gradien hijau + search pill + avatar bulat + kartu ringkasan overlap + grid layanan 4 kolom.
- [ ] Ikon fitur berupa kotak rounded pastel 56×56 dalam grid 4 kolom.
- [ ] Jadwal hari ini tampil sebagai 3 `MealScheduleCard` dengan aksen warna waktu makan.
- [ ] Paket, alamat, dan metode bayar memakai state terpilih `brandGreenSoft`.
- [ ] Alamat diubah lewat bottom sheet.
- [ ] Status berat selalu badge berwarna + teks netral.
- [ ] CTA utama pill hijau tinggi 52, **satu per layar**.
- [ ] Bottom nav sesuai Bagian 4, item aktif hijau.
- [ ] Bottom sheet punya drag handle dan radius atas 20.
- [ ] Gradien hanya hijau halus pada header/kartu ringkasan/CTA.
- [ ] Semua teks UI berbahasa Indonesia, harga format `Rp`.
- [ ] Komponen reusable dipakai, tidak ada salin-tempel antar layar.
- [ ] Tampilan aman di lebar 360–430dp, tanpa overflow, aman terhadap text scale besar.

---

## 11. Anti-Pattern (DILARANG)

- Mengganti warna merek hijau dengan warna lain, atau gradien multi-warna mencolok.
- Memakai `AppBar` Material default berwarna biru/ungu.
- Ikon polos tanpa kotak pastel pada grid fitur.
- Tombol persegi atau rounded kecil untuk CTA utama.
- Lebih dari satu CTA utama dalam satu layar.
- Elevasi tebal ala Material 2, border hitam, atau font default tanpa pengaturan.
- Memakai peta, header kuning, atau pola ride-hailing/food-delivery Gojek yang tidak relevan dengan catering langganan.
- Menampilkan fitur pengaturan alergi/pantangan makanan (menu sepenuhnya ditentukan dapur).
- Menampilkan opsi lewati hari pengiriman (pengiriman berjalan setiap hari).
- Menulis UI dalam satu file raksasa.
- Menambah library UI pihak ketiga yang mengubah tampilan tanpa izin.

---

## 12. Pemetaan Pola Gojek → Aplikasi Catering

| Pola Gojek | Padanan di aplikasi ini |
|---|---|
| Header hijau + search pill + avatar | Header Dashboard + pencarian menu/paket |
| Kartu saldo GoPay | `SubscriptionCard` / `CalorieSummaryCard` |
| Grid layanan 4 kolom | Pintasan fitur (Jadwal, Alamat, Paket, Riwayat, Nutrisi, dst.) |
| Menu "Top services" (bottom sheet) | Sheet `Semua layanan` |
| Banner promo + chip filter + konten | Promo paket + tips sehat |
| Daftar opsi terpilih hijau soft (GoRide) | Pilih paket, alamat, metode bayar |
| CTA pill hijau `withPrice` | `Lanjut` / `Bayar` dengan total harga |
| Status pesanan | `StatusBadge` pada `MealScheduleCard` |