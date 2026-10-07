import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String? price;
  final String? subtitle;
  final Gradient? gradient;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.price,
    this.subtitle,
    this.gradient,
  });

  const AppPrimaryButton.withPrice({
    super.key,
    required this.text,
    required this.price,
    this.subtitle,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    final backgroundDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      gradient: effectiveEnabled ? (gradient ?? AppColors.brandGradient) : null,
      color: effectiveEnabled ? null : AppColors.divider,
    );

    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: backgroundDecoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: effectiveEnabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                        ),
                      )
                    : price != null
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      text,
                                      style: AppTypography.cta.copyWith(fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (subtitle != null)
                                      Text(
                                        subtitle!,
                                        style: AppTypography.bodySm.copyWith(
                                          color: AppColors.surface.withValues(alpha: 0.85),
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    price!,
                                    style: AppTypography.cta.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(width: AppSpacing.xs + 2),
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 15,
                                      color: AppColors.brandGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            text,
                            style: AppTypography.cta.copyWith(
                              color: effectiveEnabled ? AppColors.surface : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
