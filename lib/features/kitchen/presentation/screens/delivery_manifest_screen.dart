import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/kitchen_repository.dart';
import '../../models/delivery_manifest_item.dart';

class DeliveryManifestScreen extends ConsumerStatefulWidget {
  const DeliveryManifestScreen({super.key});

  @override
  ConsumerState<DeliveryManifestScreen> createState() =>
      _DeliveryManifestScreenState();
}

class _DeliveryManifestScreenState extends ConsumerState<DeliveryManifestScreen> {
  String? _updatingKey;

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

  Future<void> _tandaiDikirim(DeliveryManifestItem item) async {
    final key = "${item.userId}_${item.waktuMakan}";
    setState(() => _updatingKey = key);

    try {
      final repo = ref.read(kitchenRepositoryProvider);
      await repo.markAsDelivered(
        userId: item.userId,
        waktuMakan: item.waktuMakan,
        alamatId: item.alamatId,
      );

      ref.invalidate(deliveryManifestProvider);
      ref.invalidate(kitchenDashboardProvider);

      if (mounted) {
        _showFloatingSnackBar('Status paket berhasil diubah ke Dikirim!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showFloatingSnackBar('Gagal memperbarui status: $e');
      }
    } finally {
      if (mounted) setState(() => _updatingKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manifestAsync = ref.watch(deliveryManifestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manifest Pengiriman'),
      ),
      body: manifestAsync.when(
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
                  'Gagal memuat manifest: $err',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.invalidate(deliveryManifestProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (daftarKirim) {
          if (daftarKirim.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(deliveryManifestProvider);
                await ref.read(deliveryManifestProvider.future);
              },
              color: AppColors.brandGreen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Tidak ada jadwal pengiriman untuk hari ini.',
                      style: AppTypography.bodyMd,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(deliveryManifestProvider);
              await ref.read(deliveryManifestProvider.future);
            },
            color: AppColors.brandGreen,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              itemCount: daftarKirim.length,
              itemBuilder: (context, index) {
                final item = daftarKirim[index];
                final key = "${item.userId}_${item.waktuMakan}";
                final isUpdating = _updatingKey == key;
                final bool sudahDikirim = item.isDelivered;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md + 2),
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
                          Text(
                            item.namaUser,
                            style: AppTypography.titleMd.copyWith(fontSize: 16),
                          ),
                          StatusBadge(
                            label: sudahDikirim ? 'Terkirim ✓' : 'Dimasak',
                            tone: sudahDikirim
                                ? StatusBadgeTone.green
                                : StatusBadgeTone.yellow,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Program: ${item.targetDiet}  •  Sesi: ${item.waktuMakan}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.brandGreen,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '${item.labelAlamat}: ${item.alamatLengkap}',
                              style: AppTypography.bodySm,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: sudahDikirim
                                ? AppColors.textSecondary
                                : AppColors.brandGreen,
                            side: BorderSide(
                              color: sudahDikirim
                                  ? AppColors.divider
                                  : AppColors.brandGreen,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: (sudahDikirim || isUpdating)
                              ? null
                              : () => _tandaiDikirim(item),
                          child: isUpdating
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.brandGreen,
                                  ),
                                )
                              : Text(
                                  sudahDikirim ? 'Pengiriman Selesai' : 'Tandai Selesai Masak / Dikirim',
                                  style: AppTypography.label.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
