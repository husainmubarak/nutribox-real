import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/calorie_summary_card.dart';
import '../../../../core/widgets/meal_schedule_card.dart';
import '../../../../core/widgets/promo_carousel.dart';
import '../../../../core/widgets/service_grid.dart';
import '../../../../core/widgets/service_grid_item.dart';
import '../../../../core/widgets/subscription_card.dart';
import '../../../../core/widgets/week_day_chips.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../profile/presentation/screens/nutrition_calculator_screen.dart';
import '../../../subscription/presentation/screens/address_book_screen.dart';
import '../../../subscription/presentation/screens/package_selection_screen.dart';
import '../../data/home_repository.dart';
import '../../models/home_dashboard_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTabIndex = 0;
  String _selectedJadwalDay = 'Senin';
  String _selectedTipsCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeDataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.brandGreen,
            strokeWidth: 3,
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.accentRed,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Gagal memuat data: $err',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.invalidate(homeDashboardProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          return IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildBerandaTab(data),
              _buildJadwalTab(data),
              _buildRiwayatTab(data),
              _buildAkunTab(data),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: const [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Beranda',
          ),
          AppBottomNavItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Jadwal',
          ),
          AppBottomNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Riwayat',
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 0: BERANDA (GAYA GOJEK)
  // ==========================================
  Widget _buildBerandaTab(HomeDashboardData data) {
    return RefreshIndicator(
      color: AppColors.brandGreen,
      onRefresh: () async {
        ref.invalidate(homeDashboardProvider);
        await ref.read(homeDashboardProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Gradien Hijau
            _buildGojekHeader(data),

            // Konten di bawah header (kartu overlap)
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Kartu Ringkasan (Gaya Kartu Saldo GoPay)
                    if (data.adaPaketAktif)
                      SubscriptionCard(
                        sisaHari: data.sisaHari,
                        totalHari: data.totalHari,
                        namaPaket: data.namaPaket,
                        onJadwalTap: () => setState(() => _currentTabIndex = 1),
                        onAlamatTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressBookScreen(),
                          ),
                        ),
                        onBantuanTap: _showBantuanSheet,
                      )
                    else
                      CalorieSummaryCard(
                        statusBmi: data.statusBmi,
                        targetKalori: data.targetKalori,
                        programName: data.targetDiet,
                        onActionPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PackageSelectionScreen(),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Grid Layanan 4 Kolom
                    _buildServiceGrid(data),

                    const SizedBox(height: AppSpacing.xl),

                    // 4. Jadwal Hari Ini
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Jadwal Hari Ini', style: AppTypography.titleMd),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandGreenSoft,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            data.hariIni,
                            style: AppTypography.label.copyWith(
                              color: AppColors.brandGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (data.jadwalHariIni.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.dinner_dining_outlined,
                              size: 36,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              data.adaPaketAktif
                                  ? 'Tidak ada jadwal pengiriman untuk hari ini.'
                                  : 'Belum ada jadwal aktif. Mulai langganan sekarang!',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm,
                            ),
                          ],
                        ),
                      )
                    else
                      ...data.jadwalHariIni.map((item) {
                        return MealScheduleCard(
                          waktuMakan: item.waktuMakan,
                          namaMenu: item.namaMenu,
                          alamatSingkat: item.namaAlamat,
                          jamKirim: item.jamKirim,
                          statusPengiriman: item.statusPengiriman,
                        );
                      }),

                    const SizedBox(height: AppSpacing.xl),

                    // 5. Banner Promo & Edukasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Promo & Info Spesial', style: AppTypography.titleMd),
                        Text(
                          'Lihat Semua',
                          style: AppTypography.label.copyWith(
                            color: AppColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PromoCarousel(
                      items: [
                        PromoItem(
                          tag: 'HEMAT 25%',
                          title: 'Langganan 3 Bulan',
                          subtitle: 'Diskon khusus pendaftaran paket sehat minggu ini!',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PackageSelectionScreen(),
                            ),
                          ),
                        ),
                        PromoItem(
                          tag: 'BEBAS ONGKIR',
                          title: 'Gratis Pengiriman Setiap Hari',
                          subtitle: 'Mitra dapur terbaik dikirim tepat waktu ke alamatmu.',
                          gradient: const LinearGradient(
                            colors: [AppColors.brandGreen, Color(0xFF26A69A)],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 6. Section "Tips Sehat Buat Kamu"
                    Text('Tips Sehat Buat Kamu', style: AppTypography.titleMd),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Semua',
                          'Nutrisi',
                          'Olahraga',
                          'Diet Sehat',
                        ].map((cat) {
                          final isSelected = _selectedTipsCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: AppChip(
                              label: cat,
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedTipsCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTipsCard(
                      title: 'Pentingnya Menjaga Keseimbangan Makronutrisi',
                      desc:
                          'Protein, karbohidrat kompleks, dan lemak sehat membantu metabolisme tubuh tetap prima sepanjang hari.',
                      readTime: '3 menit baca',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTipsCard(
                      title: 'Cukup Hidrasi: Kunci Sukses Target Gizi',
                      desc:
                          'Minum minimal 2 liter air setiap hari untuk mengoptimalkan penyerapan kalori dan energi harianmu.',
                      readTime: '2 menit baca',
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGojekHeader(HomeDashboardData data) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        bottom: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sapaan & Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${data.namaUser}! 👋',
                    style: AppTypography.titleLg.copyWith(
                      color: AppColors.surface,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Selamat menikmati sajian sehatmu',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _currentTabIndex = 3),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.surface,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Search Pill Read-Only
          AppSearchBar(
            placeholder: 'Cari menu, program, atau promo...',
            readOnly: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fitur pencarian segera hadir!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(HomeDashboardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: ServiceGrid(
        items: [
          ServiceGridItem(
            icon: Icons.calendar_month_outlined,
            label: 'Jadwal',
            tone: ServiceGridTone.yellow,
            onTap: () => setState(() => _currentTabIndex = 1),
          ),
          ServiceGridItem(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            tone: ServiceGridTone.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
            ),
          ),
          ServiceGridItem(
            icon: Icons.card_giftcard_outlined,
            label: 'Paket',
            tone: ServiceGridTone.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PackageSelectionScreen()),
            ),
          ),
          ServiceGridItem(
            icon: Icons.receipt_long_outlined,
            label: 'Riwayat',
            tone: ServiceGridTone.purple,
            onTap: () => setState(() => _currentTabIndex = 2),
          ),
          ServiceGridItem(
            icon: Icons.calculate_outlined,
            label: 'Nutrisi',
            tone: ServiceGridTone.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NutritionCalculatorScreen()),
            ),
          ),
          ServiceGridItem(
            icon: Icons.headset_mic_outlined,
            label: 'Bantuan',
            tone: ServiceGridTone.blue,
            onTap: _showBantuanSheet,
          ),
          ServiceGridItem(
            icon: Icons.local_offer_outlined,
            label: 'Promo',
            tone: ServiceGridTone.red,
            badgeCount: 2,
            onTap: _showPromoSheet,
          ),
          ServiceGridItem(
            icon: Icons.more_horiz_outlined,
            label: 'Lainnya',
            tone: ServiceGridTone.neutral,
            onTap: _showSemuaLayananSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard({
    required String title,
    required String desc,
    required String readTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandGreenSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.brandGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMd.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: AppTypography.bodySm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  readTime,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.brandGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: JADWAL PENGIRIMAN
  // ==========================================
  Widget _buildJadwalTab(HomeDashboardData data) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jadwal Pengiriman', style: AppTypography.titleLg),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                  ),
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                  label: const Text('Atur Alamat'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandGreen,
                  ),
                ),
              ],
            ),
          ),
          WeekDayChips(
            selectedDay: _selectedJadwalDay,
            onDaySelected: (day) => setState(() => _selectedJadwalDay = day),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              children: [
                MealScheduleCard(
                  waktuMakan: 'Sarapan',
                  namaMenu: 'Oatmeal Buah Berry & Madu Organik',
                  jamKirim: '07:00 - 08:00',
                  alamatSingkat: 'Rumah Utama',
                  statusPengiriman: 'Dimasak',
                  kalori: 450,
                ),
                MealScheduleCard(
                  waktuMakan: 'Makan Siang',
                  namaMenu: 'Ayam Panggang Lemon Rosemary & Nasi Merah',
                  jamKirim: '11:30 - 12:30',
                  alamatSingkat: 'Kantor Pusat',
                  statusPengiriman: 'Dalam perjalanan',
                  kalori: 680,
                ),
                MealScheduleCard(
                  waktuMakan: 'Makan Malam',
                  namaMenu: 'Salmon Panggang Bumbu Jahe & Sayur Kukus',
                  jamKirim: '18:00 - 19:00',
                  alamatSingkat: 'Rumah Utama',
                  statusPengiriman: 'Dimasak',
                  kalori: 520,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: RIWAYAT PESANAN
  // ==========================================
  Widget _buildRiwayatTab(HomeDashboardData data) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Text('Riwayat Langganan', style: AppTypography.titleLg),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              children: [
                _buildRiwayatCard(
                  namaPaket: data.namaPaket,
                  tgl: 'Aktif saat ini',
                  status: 'Lunas',
                  total: 'Rp950.000',
                  isActive: true,
                ),
                _buildRiwayatCard(
                  namaPaket: 'Paket Langganan 1 Bulan',
                  tgl: '15 Agustus 2026',
                  status: 'Selesai',
                  total: 'Rp950.000',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard({
    required String namaPaket,
    required String tgl,
    required String status,
    required String total,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(namaPaket, style: AppTypography.titleMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.brandGreenSoft
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.brandGreen
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(tgl, style: AppTypography.bodySm),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran', style: AppTypography.bodySm),
              Text(
                total,
                style: AppTypography.price.copyWith(
                  color: AppColors.brandGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: AKUN (GAYA GOJEK)
  // ==========================================
  Widget _buildAkunTab(HomeDashboardData data) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Profil
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.brandGreenSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: AppColors.brandGreen,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.namaUser,
                          style: AppTypography.titleLg.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Program: ${data.targetDiet}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.brandGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Target: ${data.targetKalori} kkal/hari',
                          style: AppTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Daftar Menu List Ala Gojek
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  _buildAkunMenuItem(
                    icon: Icons.fitness_center_outlined,
                    tone: ServiceGridTone.green,
                    title: 'Biodata & Profil Fisik',
                    subtitle: 'Ubah berat, tinggi, & target kalori',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NutritionCalculatorScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 56),
                  _buildAkunMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    tone: ServiceGridTone.yellow,
                    title: 'Paket Langganan',
                    subtitle: 'Pilih atau ubah paket kateringmu',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PackageSelectionScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 56),
                  _buildAkunMenuItem(
                    icon: Icons.location_on_outlined,
                    tone: ServiceGridTone.blue,
                    title: 'Alamat Pengiriman',
                    subtitle: 'Kelola daftar alamat tersimpan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressBookScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 56),
                  _buildAkunMenuItem(
                    icon: Icons.headset_mic_outlined,
                    tone: ServiceGridTone.purple,
                    title: 'Bantuan & Layanan Pelanggan',
                    subtitle: 'FAQ dan bantuan pesanan',
                    onTap: _showBantuanSheet,
                  ),
                  const Divider(indent: 56),
                  _buildAkunMenuItem(
                    icon: Icons.logout_rounded,
                    tone: ServiceGridTone.red,
                    title: 'Keluar',
                    isDanger: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAkunMenuItem({
    required IconData icon,
    required ServiceGridTone tone,
    required String title,
    String? subtitle,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    Color bg;
    Color fg;
    switch (tone) {
      case ServiceGridTone.green:
        bg = AppColors.brandGreenSoft;
        fg = AppColors.brandGreen;
        break;
      case ServiceGridTone.yellow:
        bg = AppColors.accentYellowSoft;
        fg = AppColors.accentYellow;
        break;
      case ServiceGridTone.blue:
        bg = AppColors.accentBlueSoft;
        fg = AppColors.accentBlue;
        break;
      case ServiceGridTone.purple:
        bg = AppColors.accentPurpleSoft;
        fg = AppColors.accentPurple;
        break;
      case ServiceGridTone.red:
        bg = AppColors.accentRedSoft;
        fg = AppColors.accentRed;
        break;
      case ServiceGridTone.neutral:
        bg = AppColors.divider;
        fg = AppColors.textSecondary;
        break;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: fg, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.titleMd.copyWith(
          fontSize: 15,
          color: isDanger ? AppColors.accentRed : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: AppTypography.bodySm) : null,
      trailing: isDanger ? null : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showBantuanSheet() {
    AppBottomSheet.show(
      context: context,
      title: 'Pusat Bantuan',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tim NutriBox siap membantu pengiriman atau konsultasi menu sehatmu setiap hari.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: AppColors.brandGreen),
            title: const Text('Chat WhatsApp Customer Care'),
            subtitle: const Text('08:00 - 20:00 WIB'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: AppColors.accentBlue),
            title: const Text('Email Support'),
            subtitle: const Text('support@nutribox.id'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPromoSheet() {
    AppBottomSheet.show(
      context: context,
      title: 'Kupon & Promo Spesial',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.brandGreenSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: AppColors.brandGreen),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KODE: NUTRISEHAT',
                        style: AppTypography.label.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandGreen,
                        ),
                      ),
                      const Text(
                        'Diskon Rp50.000 untuk paket 3 atau 6 bulan.',
                        style: AppTypography.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _showSemuaLayananSheet() {
    AppBottomSheet.show(
      context: context,
      title: 'Semua Layanan NutriBox',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServiceGrid(
            items: [
              ServiceGridItem(
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal',
                tone: ServiceGridTone.yellow,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentTabIndex = 1);
                },
              ),
              ServiceGridItem(
                icon: Icons.location_on_outlined,
                label: 'Alamat',
                tone: ServiceGridTone.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                  );
                },
              ),
              ServiceGridItem(
                icon: Icons.card_giftcard_outlined,
                label: 'Paket',
                tone: ServiceGridTone.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PackageSelectionScreen()),
                  );
                },
              ),
              ServiceGridItem(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat',
                tone: ServiceGridTone.purple,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentTabIndex = 2);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }
}
