import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../kitchen/presentation/screens/kitchen_dashboard_screen.dart';
import '../../../profile/presentation/screens/nutrition_calculator_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isLogin = true;
  bool _isCheckingAutoLogin = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoLogin();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAutoLogin() async {
    final role =
        await ref.read(authControllerProvider.notifier).checkAuthStatus();
    if (!mounted) return;

    if (role != UserRole.unauthenticated) {
      _navigateToDestination(role);
    } else {
      setState(() => _isCheckingAutoLogin = false);
    }
  }

  void _navigateToDestination(UserRole role) {
    if (!mounted) return;

    Widget targetScreen;
    switch (role) {
      case UserRole.kitchenPartner:
        targetScreen = const KitchenDashboardScreen();
        break;
      case UserRole.customerWithProfile:
        targetScreen = const HomeScreen();
        break;
      case UserRole.customerWithoutProfile:
        targetScreen = const NutritionCalculatorScreen();
        break;
      case UserRole.unauthenticated:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  void _showFloatingSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodySm.copyWith(color: AppColors.surface),
        ),
        backgroundColor: isError ? AppColors.textPrimary : AppColors.brandGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showFloatingSnackBar('Email dan password wajib diisi!');
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final UserRole? role = _isLogin
        ? await controller.login(email: email, password: password)
        : await controller.register(email: email, password: password);

    if (!mounted) return;

    if (role != null) {
      _navigateToDestination(role);
    } else {
      final authState = ref.read(authControllerProvider);
      final errorMsg = authState.hasError
          ? authState.error.toString()
          : 'Terjadi kesalahan pada otentikasi.';
      _showFloatingSnackBar(errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading || _isCheckingAutoLogin;

    if (_isCheckingAutoLogin) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.brandGreen,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Logo NutriBox
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.brandGreenSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sheet),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lunch_dining_rounded,
                      size: 40,
                      color: AppColors.brandGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'NutriBox',
                  style: AppTypography.titleLg.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Catering Sehat Berlangganan Setiap Hari',
                  style: AppTypography.bodySm,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Card Utama
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tab Segmented Masuk & Daftar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLogin = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _isLogin
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                    boxShadow:
                                        _isLogin ? AppShadows.card : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Masuk',
                                      style: AppTypography.label.copyWith(
                                        color: _isLogin
                                            ? AppColors.brandGreen
                                            : AppColors.textSecondary,
                                        fontWeight: _isLogin
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLogin = false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !_isLogin
                                        ? AppColors.surface
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                    boxShadow:
                                        !_isLogin ? AppShadows.card : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Daftar Baru',
                                      style: AppTypography.label.copyWith(
                                        color: !_isLogin
                                            ? AppColors.brandGreen
                                            : AppColors.textSecondary,
                                        fontWeight: !_isLogin
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Input Fields
                      Text(
                        'Email',
                        style: AppTypography.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _emailController,
                        style: AppTypography.bodyMd,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Password',
                        style: AppTypography.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _passwordController,
                        style: AppTypography.bodyMd,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // CTA Button
                      AppPrimaryButton(
                        text: _isLogin ? 'Masuk' : 'Daftar Sekarang',
                        isLoading: isLoading,
                        onPressed: _submitAuth,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
