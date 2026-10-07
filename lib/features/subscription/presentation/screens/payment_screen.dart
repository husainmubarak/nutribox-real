import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../../home/data/home_repository.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/subscription_repository.dart';
import '../../models/package_model.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final PackageModel selectedPackage;

  const PaymentScreen({
    super.key,
    required this.selectedPackage,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  String _metodePembayaran = 'GoPay';
  bool _voucherDipakai = false;

  void _showFloatingSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodySm.copyWith(color: AppColors.surface),
        ),
        backgroundColor: isError ? AppColors.textPrimary : AppColors.brandGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Future<void> _prosesPembayaran() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final diskon = _voucherDipakai ? 50000 : 0;
      final totalBayar = (widget.selectedPackage.harga - diskon).clamp(0, widget.selectedPackage.harga);

      await repo.createSubscription(
        userId: user.id,
        paketId: widget.selectedPackage.id,
        durasiHari: widget.selectedPackage.durasiHari,
        totalHarga: totalBayar,
        paymentMethod: _metodePembayaran,
        simulateImmediateActive: true,
      );

      // Refresh data beranda
      ref.invalidate(homeDashboardProvider);

      if (mounted) {
        AppBottomSheet.show(
          context: context,
          title: 'Pesanan Berhasil Aktif!',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.brandGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Terima kasih! Paket langganan sehatmu kini telah aktif dan jadwal pengiriman sudah terkonfirmasi ke dapur mitra.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                text: 'Ke Beranda',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showFloatingSnackBar('Transaksi gagal: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paket = widget.selectedPackage;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final diskon = _voucherDipakai ? 50000 : 0;
    final totalBayar = (paket.harga - diskon).clamp(0, paket.harga);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StepperHeader(
              currentStep: 2,
              totalSteps: 3,
              title: 'Konfirmasi & Pembayaran',
              subtitle: 'Selesaikan transaksi untuk mengaktifkan langganan',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ringkasan Pesanan Kartu Putih
                    Text('Ringkasan Pesanan', style: AppTypography.titleMd),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paket.namaPaket,
                                      style: AppTypography.titleMd.copyWith(fontSize: 15),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${paket.durasiHari} hari pengiriman (3x makan)',
                                      style: AppTypography.bodySm,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                currencyFormatter.format(paket.harga),
                                style: AppTypography.price,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ongkos Kirim', style: AppTypography.bodyMd),
                              Text(
                                'Gratis',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_voucherDipakai) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Diskon Promo', style: AppTypography.bodyMd),
                                Text(
                                  '-Rp50.000',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.accentRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Total Tagihan',
                                  style: AppTypography.titleMd.copyWith(fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                currencyFormatter.format(totalBayar),
                                style: AppTypography.metric.copyWith(
                                  fontSize: 20,
                                  color: AppColors.brandGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // InfoBanner Voucher Promo
                    InfoBanner(
                      text: _voucherDipakai
                          ? 'Voucher NUTRISEHAT hemat Rp50.000 terpasang!'
                          : 'Ada voucher diskon Rp50.000 untuk paket ini.',
                      actionText: _voucherDipakai ? 'Batal' : 'Pakai',
                      onAction: () {
                        setState(() => _voucherDipakai = !_voucherDipakai);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Metode Pembayaran
                    Text('Metode Pembayaran', style: AppTypography.titleMd),
                    const SizedBox(height: AppSpacing.sm),
                    OptionTile(
                      title: 'GoPay / GoPay Later',
                      subtitle: 'Bayar instan dan praktis',
                      leading: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.walletTeal,
                        size: 26,
                      ),
                      selected: _metodePembayaran == 'GoPay',
                      onTap: () => setState(() => _metodePembayaran = 'GoPay'),
                    ),
                    OptionTile(
                      title: 'Transfer Bank (BCA / Mandiri / BNI)',
                      subtitle: 'Konfirmasi otomatis via Virtual Account',
                      leading: const Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.accentBlue,
                        size: 26,
                      ),
                      selected: _metodePembayaran == 'Transfer Bank',
                      onTap: () => setState(() => _metodePembayaran = 'Transfer Bank'),
                    ),
                    OptionTile(
                      title: 'OVO / DANA / QRIS',
                      subtitle: 'Scan QRIS dari aplikasi e-wallet apa saja',
                      leading: const Icon(
                        Icons.qr_code_scanner_outlined,
                        color: AppColors.accentPurple,
                        size: 26,
                      ),
                      selected: _metodePembayaran == 'QRIS',
                      onTap: () => setState(() => _metodePembayaran = 'QRIS'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            // CTA Bayar withPrice
            Container(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppShadows.top,
              ),
              child: AppPrimaryButton.withPrice(
                text: 'Bayar Sekarang',
                subtitle: _metodePembayaran,
                price: currencyFormatter.format(totalBayar),
                isLoading: _isProcessing,
                onPressed: _prosesPembayaran,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
