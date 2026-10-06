import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_chip.dart';

class WeekDayChips extends StatelessWidget {
  final List<String> days;
  final String selectedDay;
  final ValueChanged<String> onDaySelected;

  const WeekDayChips({
    super.key,
    this.days = const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day == selectedDay;

          return AppChip(
            label: day,
            isSelected: isSelected,
            onTap: () => onDaySelected(day),
          );
        },
      ),
    );
  }
}
