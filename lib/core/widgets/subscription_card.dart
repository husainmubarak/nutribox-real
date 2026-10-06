import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class SubscriptionCard extends StatelessWidget {
  final int sisaHari;
  final int totalHari;
  final String namaPaket;
  final VoidCallback onJadwalTap;
  final VoidCallback onAlamatTap;
  final VoidCallback onBantuanTap;

  const SubscriptionCard({
    super.key,
    required this.sisaHari,
    required this.totalHari,
    required this.namaPaket,
    required this.onJadwalTap,
    required this.onAlamatTap,
    required this.onBantuanTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalHari > 0 ? (sisaHari / totalHari).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.walletGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kiri: Sisa hari & progress
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        namaPaket,
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sisa Masa Langganan',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$sisaHari',
                          style: AppTypography.metric.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'hari lagi',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surface.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandGreenLight),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Kanan: 3 aksi cepat (Jadwal, Alamat, Bantuan)
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAction(
                      icon: Icons.calendar_month_outlined,
                      label: 'Jadwal',
                      onTap: onJadwalTap,
                    ),
                    _buildQuickAction(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat',
                      onTap: onAlamatTap,
                    ),
                    _buildQuickAction(
                      icon: Icons.headset_mic_outlined,
                      label: 'Bantuan',
                      onTap: onBantuanTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.surface.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.surface,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
