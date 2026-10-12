import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/package_card.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../data/subscription_repository.dart';
import '../../models/package_model.dart';
import 'address_book_screen.dart';

class PackageSelectionScreen extends ConsumerStatefulWidget {
  const PackageSelectionScreen({super.key});

  @override
  ConsumerState<PackageSelectionScreen> createState() =>
      _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends ConsumerState<PackageSelectionScreen> {
  PackageModel? _selectedPackage;

  String? _getBadgeText(int index) {
    if (index == 0) return 'HEMAT 10%';
    if (index == 1) return 'PALING POPULER';
    if (index == 2) return 'HEMAT 25%';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(packagesFutureProvider);
    final activeSub = ref.watch(activeSubscriptionProvider).value;
    final hasActiveSub = activeSub != null;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pilih Paket Langganan'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StepperHeader(
              currentStep: 0,
              totalSteps: 3,
              title: 'Pilih Durasi Paket',
              subtitle: 'Semua paket mencakup 3x makan sehat setiap hari',
            ),
            if (hasActiveSub) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.sm,
                  AppSpacing.pagePadding,
                  AppSpacing.xs,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.accentOrange,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Langganan Masih Aktif',
                            style: AppTypography.titleMd.copyWith(
                              fontSize: 13,
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Anda masih memiliki paket aktif (${(activeSub['paket_langganan'] as Map?)?['nama_paket'] ?? 'Langganan'}) hingga ${DateFormatter.formatIndonesianDate(activeSub['tanggal_selesai']?.toString())}. Anda baru dapat memesan paket baru setelah paket ini berakhir.',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: packagesAsync.when(
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
                          'Gagal memuat paket: $err',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(packagesFutureProvider),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (daftarPaket) {
                  if (daftarPaket.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada paket tersedia.',
                        style: AppTypography.bodyMd,
                      ),
                    );
                  }

                  // Default pilih paket pertama bila belum ada pilihan
                  if (_selectedPackage == null && daftarPaket.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _selectedPackage = daftarPaket.first);
                      }
                    });
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    itemCount: daftarPaket.length,
                    itemBuilder: (context, index) {
                      final PackageModel paket = daftarPaket[index];
                      final isSelected = _selectedPackage?.id == paket.id;

                      return PackageCard(
                        namaPaket: paket.namaPaket,
                        durasiHari: paket.durasiHari,
                        harga: paket.harga,
                        badgeText: _getBadgeText(index),
                        selected: isSelected,
                        onTap: () {
                          setState(() => _selectedPackage = paket);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // CTA Bawah withPrice
            Container(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppShadows.top,
              ),
              child: AppPrimaryButton.withPrice(
                text: hasActiveSub ? 'Langganan Masih Aktif' : 'Lanjut ke Alamat',
                subtitle: hasActiveSub
                    ? 'Selesaikan paket aktif saat ini'
                    : _selectedPackage?.namaPaket,
                price: _selectedPackage != null
                    ? currencyFormatter.format(_selectedPackage!.harga)
                    : 'Rp0',
                isEnabled: !hasActiveSub && _selectedPackage != null,
                onPressed: () {
                  if (hasActiveSub) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Anda masih memiliki paket aktif hingga ${DateFormatter.formatIndonesianDate(activeSub['tanggal_selesai']?.toString())}. Paket baru dapat dipesan setelah masa aktif berakhir.',
                        ),
                        backgroundColor: AppColors.accentOrange,
                      ),
                    );
                    return;
                  }
                  if (_selectedPackage == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressBookScreen(
                        selectedPackage: _selectedPackage,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
