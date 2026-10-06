import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';

class AuthController extends Notifier<AsyncValue<UserRole?>> {
  @override
  AsyncValue<UserRole?> build() {
    return const AsyncValue.data(null);
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Cek sesi aktif saat aplikasi dibuka (Auto-login)
  Future<UserRole> checkAuthStatus() async {
    final session = _repository.currentSession;
    if (session == null) {
      return UserRole.unauthenticated;
    }
    try {
      final role = await _repository.determineUserRole(session.user.id);
      return role;
    } catch (_) {
      return UserRole.unauthenticated;
    }
  }

  /// Login dengan email & password
  Future<UserRole?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.signIn(email: email, password: password);
      final user = response.user;
      if (user == null) {
        state = AsyncValue.error('User tidak ditemukan', StackTrace.current);
        return null;
      }

      final role = await _repository.determineUserRole(user.id);
      state = AsyncValue.data(role);
      return role;
    } on AuthException catch (e, st) {
      state = AsyncValue.error(e.message, st);
      return null;
    } catch (e, st) {
      state = AsyncValue.error('Terjadi kesalahan: $e', st);
      return null;
    }
  }

  /// Daftar akun baru
  Future<UserRole?> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.signUp(email: email, password: password);
      if (response.user == null) {
        state = AsyncValue.error('Pendaftaran gagal', StackTrace.current);
        return null;
      }

      // Pastikan session aktif di client. Jika signUp tidak langsung menghasilkan session,
      // lakukan auto-login agar token autentikasi terpasang sebelum navigasi ke profil.
      if (_repository.currentSession == null) {
        await _repository.signIn(email: email, password: password);
      }

      // User baru selalu belum punya profil gizi
      const role = UserRole.customerWithoutProfile;
      state = const AsyncValue.data(role);
      return role;
    } on AuthException catch (e, st) {
      state = AsyncValue.error(e.message, st);
      return null;
    } catch (e, st) {
      state = AsyncValue.error('Terjadi kesalahan: $e', st);
      return null;
    }
  }

  /// Keluar dari akun
  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(UserRole.unauthenticated);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<UserRole?>>(AuthController.new);
