import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';

enum UserRole {
  kitchenPartner,
  customerWithProfile,
  customerWithoutProfile,
  unauthenticated,
}

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Menentukan rute/role user setelah login atau saat auto-login
  Future<UserRole> determineUserRole(String userId) async {
    // 1. Cek apakah user adalah Mitra Dapur
    final mitraData = await _client
        .from(AppConstants.tableMitraDapur)
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (mitraData != null) {
      return UserRole.kitchenPartner;
    }

    // 2. Cek apakah user adalah Pelanggan dengan profil gizi lengkap
    final userProfile = await _client
        .from(AppConstants.tableUsers)
        .select('target_diet')
        .eq('id', userId)
        .maybeSingle();

    if (userProfile != null && userProfile['target_diet'] != null) {
      return UserRole.customerWithProfile;
    }

    // 3. User belum mengisi profil gizi
    return UserRole.customerWithoutProfile;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});
