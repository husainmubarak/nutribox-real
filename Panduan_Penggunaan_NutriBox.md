# Panduan Penggunaan NutriBox

Panduan ini menjelaskan alur demonstrasi aplikasi dari sisi user dan mitra dapur. Kredensial akun demo tersedia di [Kredensial_Akun_Demo_NutriBox.md](Kredensial_Akun_Demo_NutriBox.md).

## A. Menggunakan aplikasi sebagai user

### 1. Masuk atau mendaftar

1. Buka NutriBox.
2. Masuk dengan akun user demo, atau pilih **Daftar** untuk membuat akun baru.
3. Registrasi di aplikasi membuat akun **user**. Akun dapur disiapkan terpisah sebagai akun demo dan tidak dibuat melalui formulir registrasi user.

### 2. Lengkapi profil gizi

1. Setelah registrasi, isi nama lengkap, jenis kelamin, tanggal lahir, berat, tinggi, tingkat aktivitas, dan target diet.
2. Simpan profil untuk menghitung status BMI dan target kalori.
3. Pilih salah satu program: **Bulking**, **Cutting**, atau **Jaga BB**.

### 3. Tambahkan alamat dan titik lokasi

1. Dari beranda, buka **Alamat** atau mulai alur langganan dan pilih **Atur Alamat**.
2. Pilih **Tambah Alamat Baru**, lalu isi label dan alamat lengkap.
3. Tekan **Tentukan Titik di Peta / GPS**. Ketuk lokasi pada peta atau gunakan tombol lokasi perangkat; izinkan akses lokasi jika diminta.
4. Konfirmasi titik dan simpan alamat.
5. Aplikasi mengaitkan alamat dengan dapur yang koordinatnya paling dekat berdasarkan jarak garis lurus. Pastikan titik peta benar. Jarak ini bukan rute jalan.

### 4. Berlangganan

1. Pilih **Paket** dari beranda, lalu pilih durasi paket.
2. Atur alamat untuk setiap hari dan waktu makan (**Sarapan**, **Siang**, **Malam**). Opsi **Samakan Semua Hari** menyalin pengaturan hari yang dipilih ke hari lainnya.
3. Lanjutkan ke pembayaran, tinjau ringkasan dan pilih metode yang ditampilkan.
4. Tekan **Bayar Sekarang**. Pada versi demo, pembayaran langsung disimulasikan menjadi lunas dan paket aktif; aplikasi belum menagih uang sungguhan melalui GoPay, transfer, atau QRIS.
5. Aplikasi membuat jadwal mingguan untuk paket aktif. Satu user hanya dapat memiliki satu langganan aktif pada satu waktu.

### 5. Pantau pesanan

- **Beranda** menampilkan ringkasan langganan dan jadwal hari ini.
- Tab **Jadwal** menampilkan pengiriman per hari.
- Tab **Riwayat** menampilkan transaksi langganan.
- Tab **Akun** menampilkan profil serta ringkasan target diet dan kalori.
- Status awal pengiriman adalah **Dimasak**. Status menjadi **Terkirim** setelah mitra dapur memperbarui manifest.
- Tarik layar ke bawah pada halaman yang mendukung refresh untuk memuat data terbaru.

## B. Menggunakan aplikasi sebagai mitra dapur

### 1. Masuk

1. Keluar dari akun user melalui tab **Akun**.
2. Masuk menggunakan salah satu akun dapur pada tabel kredensial.
3. Akun dapur yang sudah disiapkan diarahkan ke dasbor dapur berdasarkan profilnya di tabel `mitra_dapur`.

### 2. Input menu

1. Dari dasbor, pilih **Input Menu**.
2. Pilih tanggal, program diet, dan waktu makan.
3. Masukkan nama menu. Deskripsi atau kandungan gizi dapat diisi sebagai keterangan tambahan.
4. Tekan **Simpan Menu**.
5. Menu yang disimpan menjadi menu dari dapur yang sedang login. Untuk kebutuhan pengiriman hari ini, pastikan menu pada tanggal, diet, dan waktu makan yang sesuai tersedia sebelum manifest diproses.

### 3. Proses manifest pengiriman

1. Dari dasbor, buka **Manifest** atau **Lihat Manifest Pengiriman**.
2. Periksa daftar pelanggan, program diet, waktu makan, dan alamat pengiriman yang ditampilkan.
3. Siapkan pesanan dan lakukan pengantaran sesuai daftar.
4. Setelah pesanan benar-benar diserahkan, tekan tombol pembaruan status pada item manifest untuk mengubah status menjadi **Terkirim**.
5. Refresh dasbor/manifest bila data belum terlihat. Status tersebut juga digunakan di tampilan jadwal user.

### 4. Jika manifest kosong

- Pastikan user memiliki paket aktif dan jadwal/alamat sudah tersimpan.
- Pastikan alamat user menunjuk ke dapur ini. Penentuan dapur dilakukan saat alamat dibuat berdasarkan titik koordinat terdekat.
- Pastikan tanggal, diet, dan waktu makan cocok dengan menu yang sudah diinput.
- Akun dapur Banjarbaru dan Banjarmasin ditambahkan untuk demonstrasi. User demo yang alamatnya masih di Makassar tidak otomatis berpindah ke dapur Kalimantan; buat alamat uji dengan titik lokasi di wilayah yang sesuai.

## Catatan data demo

- Nama, alamat, koordinat dapur baru, dan sebagian data akun adalah data demonstrasi. Koordinat Banjarbaru dan Banjarmasin adalah perkiraan pusat kota, bukan titik alamat dapur yang telah disurvei.
- Harga dan metode pembayaran pada layar pembayaran adalah bagian dari simulasi. Tidak ada transaksi finansial nyata.
- Jangan memakai akun atau kata sandi pada berkas kredensial untuk layanan produksi. Ganti kata sandi sebelum berbagi APK atau data proyek di luar lingkungan demo.
