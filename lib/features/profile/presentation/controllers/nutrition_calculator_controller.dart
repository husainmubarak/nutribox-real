import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_repository.dart';
import '../../models/user_profile.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/data/auth_repository.dart';

class NutritionCalculationResult {
  final double bmi;
  final String statusBmi;
  final String targetDiet;
  final int targetKalori;

  const NutritionCalculationResult({
    required this.bmi,
    required this.statusBmi,
    required this.targetDiet,
    required this.targetKalori,
  });
}

class NutritionCalculatorController extends Notifier<AsyncValue<NutritionCalculationResult?>> {
  @override
  AsyncValue<NutritionCalculationResult?> build() {
    return const AsyncValue.data(null);
  }

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  NutritionCalculationResult calculate({
    required double beratBadan,
    required double tinggiBadan,
    required int umur,
    required String gender,
    required double pengaliAktivitas,
  }) {
    final tinggiMeter = tinggiBadan / 100;
    final bmi = beratBadan / (tinggiMeter * tinggiMeter);

    String statusBmi;
    int nilaiTarget;
    String targetDiet;

    if (bmi < 18.5) {
      statusBmi = 'Kurus';
      nilaiTarget = 500;
      targetDiet = 'Bulking';
    } else if (bmi < 25) {
      statusBmi = 'Ideal';
      nilaiTarget = 0;
      targetDiet = 'Jaga BB';
    } else if (bmi < 30) {
      statusBmi = 'Overweight';
      nilaiTarget = -500;
      targetDiet = 'Cutting';
    } else {
      statusBmi = 'Obesitas';
      nilaiTarget = -500;
      targetDiet = 'Cutting';
    }

    double bmr;
    if (gender == 'L') {
      bmr = (10 * beratBadan) + (6.25 * tinggiBadan) - (5 * umur) + 5;
    } else {
      bmr = (10 * beratBadan) + (6.25 * tinggiBadan) - (5 * umur) - 161;
    }

    final tdee = bmr * pengaliAktivitas;
    final hasilKalori = (tdee + nilaiTarget).round();

    return NutritionCalculationResult(
      bmi: bmi,
      statusBmi: statusBmi,
      targetDiet: targetDiet,
      targetKalori: hasilKalori,
    );
  }

  Future<NutritionCalculationResult?> calculateAndSave({
    required String namaLengkap,
    required String gender,
    required String tanggalLahir,
    required int umur,
    required double beratBadan,
    required double tinggiBadan,
    required double pengaliAktivitas,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Coba currentUserProvider dulu, jika null ambil dari AuthRepository
      // (bisa terjadi saat stream authState belum emit setelah registrasi)
      final user = ref.read(currentUserProvider) ??
          ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('User belum terautentikasi');
      }

      final result = calculate(
        beratBadan: beratBadan,
        tinggiBadan: tinggiBadan,
        umur: umur,
        gender: gender,
        pengaliAktivitas: pengaliAktivitas,
      );

      final profile = UserProfile(
        id: user.id,
        namaLengkap: namaLengkap,
        gender: gender,
        tanggalLahir: tanggalLahir,
        tinggiBadan: tinggiBadan,
        beratBadan: beratBadan,
        targetDiet: result.targetDiet,
        tingkatAktivitas: pengaliAktivitas.toString(),
        statusBmi: result.statusBmi,
        targetKaloriHarian: result.targetKalori,
      );

      await _repository.saveProfile(profile);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final nutritionCalculatorControllerProvider = NotifierProvider<
    NutritionCalculatorController,
    AsyncValue<NutritionCalculationResult?>>(NutritionCalculatorController.new);
