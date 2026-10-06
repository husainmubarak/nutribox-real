import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/service_grid.dart';
import '../../../../core/widgets/service_grid_item.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../data/kitchen_repository.dart';
import 'delivery_manifest_screen.dart';
import 'menu_input_screen.dart';

class KitchenDashboardScreen extends ConsumerWidget {
  const KitchenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(kitchenDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NutriBox Dapur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MenuInputScreen()),
          );
        },
        backgroundColor: AppColors.brandGreen,
        icon: const Icon(Icons.add, color: AppColors.surface),
        label: const Text(
          'Input Menu',
          style: TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: dashboardAsync.when(
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
                  'Gagal memuat data dasbor: $err',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.invalidate(kitchenDashboardProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(kitchenDashboardProvider);
              await ref.read(kitchenDashboardProvider.future);
            },
            color: AppColors.brandGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.namaDapur,
                    style: AppTypography.titleLg.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rekap Operasional: ${data.hariIni}',
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // KARTU TOTAL PORSI (Gaya SubscriptionCard)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL PORSI HARI INI',
                          style: AppTypography.label.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${data.totalPorsi}',
                          style: AppTypography.metric.copyWith(
                            fontSize: 48,
                            color: AppColors.surface,
                          ),
                        ),
                        Text(
                          'Porsi Makanan Siap Masak',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.surface.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // PINTASAN AKSI CEPAT
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: ServiceGrid(
                      items: [
                        ServiceGridItem(
                          icon: Icons.delivery_dining_outlined,
                          label: 'Manifest',
                          tone: ServiceGridTone.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeliveryManifestScreen(),
                            ),
                          ),
                        ),
                        ServiceGridItem(
                          icon: Icons.restaurant_menu_outlined,
                          label: 'Input Menu',
                          tone: ServiceGridTone.yellow,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MenuInputScreen(),
                            ),
                          ),
                        ),
                        ServiceGridItem(
                          icon: Icons.history_outlined,
                          label: 'Riwayat',
                          tone: ServiceGridTone.blue,
                          onTap: () {},
                        ),
                        ServiceGridItem(
                          icon: Icons.settings_outlined,
                          label: 'Pengaturan',
                          tone: ServiceGridTone.neutral,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Rincian Berdasarkan Program Diet',
                    style: AppTypography.titleMd,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (data.rekapPesanan.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          'Belum ada pesanan masuk untuk hari ini.',
                          style: AppTypography.bodySm,
                        ),
                      ),
                    )
                  else
                    ...data.rekapPesanan.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.card,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.brandGreenSoft,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: AppColors.brandGreen,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: AppTypography.titleMd.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.value} Porsi',
                              style: AppTypography.price.copyWith(
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppSpacing.xl),

                  AppPrimaryButton(
                    text: 'Lihat Manifest Pengiriman',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryManifestScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
