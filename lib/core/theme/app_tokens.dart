import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const brandGreen = Color(0xFF00AA13);
  static const brandGreenLight = Color(0xFF4CCB5A);
  static const brandGreenDark = Color(0xFF008A0F);
  static const brandGreenSoft = Color(0xFFE3F6E5);
  static const walletTeal = Color(0xFF0F7C99);
  static const accentRed = Color(0xFFEE2737);
  static const accentRedSoft = Color(0xFFFDE4E6);
  static const accentBlue = Color(0xFF1B8AD3);
  static const accentBlueSoft = Color(0xFFDCEFFB);
  static const accentPurple = Color(0xFF7A3FA3);
  static const accentPurpleSoft = Color(0xFFEFE3F7);
  static const accentOrange = Color(0xFFF26B21);
  static const accentOrangeSoft = Color(0xFFFFE9DC);
  static const accentYellow = Color(0xFFFFB020);
  static const accentYellowSoft = Color(0xFFFFF1D6);
  static const textPrimary = Color(0xFF1C1C1C);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider = Color(0xFFE8E8E8);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF4F5F7);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandGreen, brandGreenLight],
  );

  static const walletGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [walletTeal, Color(0xFF1A9BBF)],
  );

  // Semantic Aliases
  static const mealBreakfast = accentYellow;
  static const mealBreakfastSoft = accentYellowSoft;
  static const mealLunch = brandGreen;
  static const mealLunchSoft = brandGreenSoft;
  static const mealDinner = accentPurple;
  static const mealDinnerSoft = accentPurpleSoft;

  static const statusUnder = accentBlue;
  static const statusUnderSoft = accentBlueSoft;
  static const statusIdeal = brandGreen;
  static const statusIdealSoft = brandGreenSoft;
  static const statusOver = accentOrange;
  static const statusOverSoft = accentOrangeSoft;

  static const deliveryCooking = accentYellow;
  static const deliveryCookingSoft = accentYellowSoft;
  static const deliveryOnTheWay = accentBlue;
  static const deliveryOnTheWaySoft = accentBlueSoft;
  static const deliveryDone = brandGreen;
  static const deliveryDoneSoft = brandGreenSoft;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double pagePadding = 16.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double sheet = 20.0;
  static const double pill = 999.0;
}

class AppShadows {
  AppShadows._();

  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> top = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, -2),
    ),
  ];
}

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle cta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );
}
