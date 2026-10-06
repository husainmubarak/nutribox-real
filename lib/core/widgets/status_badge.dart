import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

enum StatusBadgeTone {
  green,
  yellow,
  blue,
  orange,
  red,
  purple,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeTone tone;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.green,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (tone) {
      case StatusBadgeTone.green:
        bg = AppColors.brandGreenSoft;
        fg = AppColors.brandGreen;
        break;
      case StatusBadgeTone.yellow:
        bg = AppColors.accentYellowSoft;
        fg = AppColors.accentYellow;
        break;
      case StatusBadgeTone.blue:
        bg = AppColors.accentBlueSoft;
        fg = AppColors.accentBlue;
        break;
      case StatusBadgeTone.orange:
        bg = AppColors.accentOrangeSoft;
        fg = AppColors.accentOrange;
        break;
      case StatusBadgeTone.red:
        bg = AppColors.accentRedSoft;
        fg = AppColors.accentRed;
        break;
      case StatusBadgeTone.purple:
        bg = AppColors.accentPurpleSoft;
        fg = AppColors.accentPurple;
        break;
      case StatusBadgeTone.neutral:
        bg = AppColors.divider;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
