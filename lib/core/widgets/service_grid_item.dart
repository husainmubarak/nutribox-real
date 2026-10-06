import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

enum ServiceGridTone {
  green,
  red,
  blue,
  purple,
  yellow,
  neutral,
}

class ServiceGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ServiceGridTone tone;
  final VoidCallback onTap;
  final int? badgeCount;

  const ServiceGridItem({
    super.key,
    required this.icon,
    required this.label,
    this.tone = ServiceGridTone.green,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (tone) {
      case ServiceGridTone.green:
        bg = AppColors.brandGreenSoft;
        fg = AppColors.brandGreen;
        break;
      case ServiceGridTone.red:
        bg = AppColors.accentRedSoft;
        fg = AppColors.accentRed;
        break;
      case ServiceGridTone.blue:
        bg = AppColors.accentBlueSoft;
        fg = AppColors.accentBlue;
        break;
      case ServiceGridTone.purple:
        bg = AppColors.accentPurpleSoft;
        fg = AppColors.accentPurple;
        break;
      case ServiceGridTone.yellow:
        bg = AppColors.accentYellowSoft;
        fg = AppColors.accentYellow;
        break;
      case ServiceGridTone.neutral:
        bg = AppColors.background;
        fg = AppColors.textPrimary;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Icon(icon, color: fg, size: 28),
                ),
              ),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            label,
            style: AppTypography.label.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
