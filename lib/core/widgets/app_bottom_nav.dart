import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;

  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.top,
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.brandGreen,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: items.map((item) {
            Widget iconWidget = Icon(item.icon, size: 24);
            Widget activeIconWidget = Icon(item.activeIcon ?? item.icon, size: 24);

            if (item.badgeCount != null && item.badgeCount! > 0) {
              iconWidget = Badge(
                backgroundColor: AppColors.accentRed,
                label: Text('${item.badgeCount}'),
                child: iconWidget,
              );
              activeIconWidget = Badge(
                backgroundColor: AppColors.accentRed,
                label: Text('${item.badgeCount}'),
                child: activeIconWidget,
              );
            }

            return BottomNavigationBarItem(
              icon: iconWidget,
              activeIcon: activeIconWidget,
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
