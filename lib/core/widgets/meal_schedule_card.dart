import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'status_badge.dart';

class MealScheduleCard extends StatelessWidget {
  final String waktuMakan;
  final String namaMenu;
  final String? jamKirim;
  final String? alamatSingkat;
  final String? statusPengiriman;
  final int? kalori;
  final VoidCallback? onTap;

  const MealScheduleCard({
    super.key,
    required this.waktuMakan,
    required this.namaMenu,
    this.jamKirim,
    this.alamatSingkat,
    this.statusPengiriman,
    this.kalori,
    this.onTap,
  });

  Color _getMealColor() {
    switch (waktuMakan.toLowerCase()) {
      case 'sarapan':
        return AppColors.mealBreakfast;
      case 'siang':
      case 'makan siang':
        return AppColors.mealLunch;
      case 'malam':
      case 'makan malam':
        return AppColors.mealDinner;
      default:
        return AppColors.brandGreen;
    }
  }

  Color _getMealBgColor() {
    switch (waktuMakan.toLowerCase()) {
      case 'sarapan':
        return AppColors.mealBreakfastSoft;
      case 'siang':
      case 'makan siang':
        return AppColors.mealLunchSoft;
      case 'malam':
      case 'makan malam':
        return AppColors.mealDinnerSoft;
      default:
        return AppColors.brandGreenSoft;
    }
  }

  StatusBadgeTone _getStatusTone(String? status) {
    if (status == null) return StatusBadgeTone.neutral;
    final lower = status.toLowerCase();
    if (lower.contains('masak') || lower.contains('dimasak')) {
      return StatusBadgeTone.yellow;
    } else if (lower.contains('kirim') || lower.contains('perjalanan')) {
      return StatusBadgeTone.blue;
    } else if (lower.contains('sampai') || lower.contains('selesai') || lower.contains('terkirim')) {
      return StatusBadgeTone.green;
    }
    return StatusBadgeTone.neutral;
  }

  IconData _getMealIcon() {
    switch (waktuMakan.toLowerCase()) {
      case 'sarapan':
        return Icons.wb_sunny_outlined;
      case 'siang':
      case 'makan siang':
        return Icons.lunch_dining_outlined;
      case 'malam':
      case 'makan malam':
        return Icons.nights_stay_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealColor = _getMealColor();
    final mealBg = _getMealBgColor();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border(
          left: BorderSide(
            color: mealColor,
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon waktu makan
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: mealBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getMealIcon(),
                    color: mealColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Info menu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              waktuMakan,
                              style: AppTypography.label.copyWith(
                                color: mealColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (statusPengiriman != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            StatusBadge(
                              label: statusPengiriman!,
                              tone: _getStatusTone(statusPengiriman),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        namaMenu,
                        style: AppTypography.titleMd.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: 2,
                        children: [
                          if (jamKirim != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 13,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  jamKirim!,
                                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          if (kalori != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_outlined,
                                  size: 13,
                                  color: AppColors.accentOrange,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$kalori kkal',
                                  style: AppTypography.bodySm.copyWith(
                                    fontSize: 11,
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (alamatSingkat != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                alamatSingkat!,
                                style: AppTypography.bodySm.copyWith(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
