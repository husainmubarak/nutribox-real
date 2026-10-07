import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'status_badge.dart';

class CalorieSummaryCard extends StatelessWidget {
  final String statusBmi;
  final int targetKalori;
  final String? programName;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const CalorieSummaryCard({
    super.key,
    required this.statusBmi,
    required this.targetKalori,
    this.programName,
    this.onActionPressed,
    this.actionText = 'Berlangganan',
  });

  StatusBadgeTone _getTone(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('kurus') || lower.contains('under')) {
      return StatusBadgeTone.blue;
    } else if (lower.contains('ideal')) {
      return StatusBadgeTone.green;
    } else {
      return StatusBadgeTone.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: StatusBadge(
                  label: 'Status: $statusBmi',
                  tone: _getTone(statusBmi),
                ),
              ),
              if (programName != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      programName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kebutuhan Kalori Harian',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.surface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$targetKalori',
                style: AppTypography.metric.copyWith(
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'kkal/hari',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onActionPressed != null && actionText != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.brandGreen,
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    shape: const StadiumBorder(),
                    textStyle: AppTypography.label.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: onActionPressed,
                  child: Text(actionText!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
