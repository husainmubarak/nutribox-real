import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class StepperHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;

  const StepperHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isDone = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? AppSpacing.xs : 0,
                  ),
                  decoration: BoxDecoration(
                    color: (isDone || isCurrent)
                        ? AppColors.brandGreen
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.titleLg,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySm,
            ),
          ],
        ],
      ),
    );
  }
}
