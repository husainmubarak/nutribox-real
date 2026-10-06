import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider untuk Supabase Client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider stream auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

/// Provider user saat ini (nullable)
/// Membaca langsung dari Supabase auth tanpa bergantung pada
/// async state stream agar tidak mengembalikan null saat stream
/// belum mengirimkan event pertama (misal setelah registrasi).
final currentUserProvider = Provider<User?>((ref) {
  // Tetap watch stream agar provider di-rebuild saat auth state berubah
  ref.watch(authStateChangesProvider);
  // Gunakan Supabase.instance.client sebagai sumber kebenaran agar
  // tidak tergantung pada apakah stream sudah emit event atau belum
  return Supabase.instance.client.auth.currentUser;
});
