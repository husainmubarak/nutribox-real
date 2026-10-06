import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class MealAddressTile extends StatelessWidget {
  final String waktuMakan;
  final String labelAlamat;
  final String alamatLengkap;
  final VoidCallback onUbahTap;

  const MealAddressTile({
    super.key,
    required this.waktuMakan,
    required this.labelAlamat,
    required this.alamatLengkap,
    required this.onUbahTap,
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
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: mealBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getMealIcon(),
              color: mealColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waktuMakan,
                  style: AppTypography.titleMd.copyWith(
                    fontSize: 14,
                    color: mealColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  labelAlamat,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alamatLengkap,
                  style: AppTypography.bodySm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandGreen,
              side: const BorderSide(color: AppColors.brandGreen),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              minimumSize: const Size(0, 32),
              textStyle: AppTypography.label.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            onPressed: onUbahTap,
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }
}
