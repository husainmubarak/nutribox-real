import 'package:flutter_test/flutter_test.dart';
import 'package:nutribox/features/profile/presentation/controllers/nutrition_calculator_controller.dart';

void main() {
  group('NutritionCalculator Tests', () {
    final controller = NutritionCalculatorController();

    test('calculates Bulking correctly for underweight BMI (< 18.5)', () {
      // 50kg, 180cm -> BMI = 50 / (1.8 * 1.8) = 15.43 (< 18.5)
      final result = controller.calculate(
        beratBadan: 50,
        tinggiBadan: 180,
        umur: 22,
        gender: 'L',
        pengaliAktivitas: 1.2,
      );

      expect(result.statusBmi, 'Kurus');
      expect(result.targetDiet, 'Bulking');
      expect(result.bmi, closeTo(15.43, 0.1));
      // BMR = (10*50) + (6.25*180) - (5*22) + 5 = 500 + 1125 - 110 + 5 = 1520
      // TDEE = 1520 * 1.2 = 1824
      // Bulking target = +500 => 2324
      expect(result.targetKalori, 2324);
    });

    test('calculates Jaga BB correctly for ideal BMI (18.5 - 24.9)', () {
      // 65kg, 170cm -> BMI = 65 / (1.7 * 1.7) = 22.49 (Ideal)
      final result = controller.calculate(
        beratBadan: 65,
        tinggiBadan: 170,
        umur: 25,
        gender: 'L',
        pengaliAktivitas: 1.375,
      );

      expect(result.statusBmi, 'Ideal');
      expect(result.targetDiet, 'Jaga BB');
      expect(result.bmi, closeTo(22.49, 0.1));
      // BMR = (10*65) + (6.25*170) - (5*25) + 5 = 650 + 1062.5 - 125 + 5 = 1592.5
      // TDEE = 1592.5 * 1.375 = 2189.68
      // Ideal target = +0 => 2190
      expect(result.targetKalori, 2190);
    });

    test('calculates Cutting correctly for female with overweight BMI (>= 25)', () {
      // 70kg, 160cm -> BMI = 70 / (1.6 * 1.6) = 27.34 (Overweight)
      final result = controller.calculate(
        beratBadan: 70,
        tinggiBadan: 160,
        umur: 30,
        gender: 'P',
        pengaliAktivitas: 1.2,
      );

      expect(result.statusBmi, 'Overweight');
      expect(result.targetDiet, 'Cutting');
      expect(result.bmi, closeTo(27.34, 0.1));
      // Female BMR = (10*70) + (6.25*160) - (5*30) - 161 = 700 + 1000 - 150 - 161 = 1389
      // TDEE = 1389 * 1.2 = 1666.8
      // Cutting target = -500 => 1167
      expect(result.targetKalori, 1167);
    });
  });
}
