import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_tokens.dart';

class PackageCard extends StatelessWidget {
  final String namaPaket;
  final int durasiHari;
  final int harga;
  final String? badgeText;
  final bool selected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.namaPaket,
    required this.durasiHari,
    required this.harga,
    this.badgeText,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final hargaPerHari = durasiHari > 0 ? (harga / durasiHari).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? AppColors.brandGreenSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? AppColors.brandGreen : AppColors.divider,
          width: selected ? 1.5 : 1.0,
        ),
        boxShadow: selected ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            namaPaket,
                            style: AppTypography.titleMd.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandGreen,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                badgeText!,
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Durasi $durasiHari hari (3x makan sehari)',
                        style: AppTypography.bodySm,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currencyFormatter.format(harga),
                            style: AppTypography.price.copyWith(
                              fontSize: 18,
                              color: AppColors.brandGreen,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '(${currencyFormatter.format(hargaPerHari)}/hari)',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.brandGreen : AppColors.divider,
                      width: 2,
                    ),
                    color: selected ? AppColors.brandGreen : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.surface,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
