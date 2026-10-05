import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // Jalankan pemeriksaan status auto-login setelah frame pertama
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

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading || _isCheckingAutoLogin;

    if (_isCheckingAutoLogin) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.food_bank, size: 100, color: Colors.green),
              const SizedBox(height: 10),
              const Text(
                'NutriBox',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitAuth,
                      child: Text(
                        _isLogin ? 'MASUK' : 'DAFTAR SEKARANG',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Belum punya akun? Daftar di sini'
                      : 'Sudah punya akun? Masuk di sini',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
