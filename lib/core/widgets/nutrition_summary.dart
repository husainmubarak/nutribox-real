import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class NutritionSummary extends StatelessWidget {
  final int kalori;
  final double protein;
  final double karbo;
  final double lemak;

  const NutritionSummary({
    super.key,
    required this.kalori,
    required this.protein,
    required this.karbo,
    required this.lemak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMacroItem(
            label: 'Kalori',
            value: '$kalori',
            unit: 'kkal',
            color: AppColors.accentOrange,
            bgColor: AppColors.accentOrangeSoft,
            icon: Icons.local_fire_department,
          ),
          _buildMacroItem(
            label: 'Protein',
            value: protein.toStringAsFixed(1),
            unit: 'g',
            color: AppColors.accentRed,
            bgColor: AppColors.accentRedSoft,
            icon: Icons.fitness_center,
          ),
          _buildMacroItem(
            label: 'Karbo',
            value: karbo.toStringAsFixed(1),
            unit: 'g',
            color: AppColors.accentYellow,
            bgColor: AppColors.accentYellowSoft,
            icon: Icons.grain,
          ),
          _buildMacroItem(
            label: 'Lemak',
            value: lemak.toStringAsFixed(1),
            unit: 'g',
            color: AppColors.accentPurple,
            bgColor: AppColors.accentPurpleSoft,
            icon: Icons.water_drop,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.titleMd.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: AppTypography.bodySm.copyWith(
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
