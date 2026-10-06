import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'service_grid_item.dart';

class ServiceGrid extends StatelessWidget {
  final List<ServiceGridItem> items;

  const ServiceGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }
}
