import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/calorie_summary_card.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../subscription/presentation/screens/package_selection_screen.dart';
import '../controllers/nutrition_calculator_controller.dart';

class NutritionCalculatorScreen extends ConsumerStatefulWidget {
  const NutritionCalculatorScreen({super.key});

  @override
  ConsumerState<NutritionCalculatorScreen> createState() =>
      _NutritionCalculatorScreenState();
}

class _NutritionCalculatorScreenState
    extends ConsumerState<NutritionCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tglLahirController;
  late final TextEditingController _namaController;
  late final TextEditingController _beratController;
  late final TextEditingController _tinggiController;

  String _gender = 'L';
  DateTime? _tanggalLahir;
  int _umur = 25;
  double _pengaliAktivitas = 1.2;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _tglLahirController = TextEditingController();
    _beratController = TextEditingController(text: '65');
    _tinggiController = TextEditingController(text: '170');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tglLahirController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? now.subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandGreen,
              onPrimary: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _tanggalLahir = picked;
        _tglLahirController.text = DateFormatter.toIsoDateString(picked);
        _umur = DateFormatter.calculateAge(picked, now);
      });
    }
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

  Future<void> _hitungDanSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final berat =
        double.tryParse(_beratController.text.trim().replaceAll(',', '.')) ??
            65.0;
    final tinggi =
        double.tryParse(_tinggiController.text.trim().replaceAll(',', '.')) ??
            170.0;

    final controller = ref.read(nutritionCalculatorControllerProvider.notifier);
    final result = await controller.calculateAndSave(
      namaLengkap: _namaController.text.trim(),
      gender: _gender,
      tanggalLahir: _tglLahirController.text.trim(),
      umur: _umur,
      beratBadan: berat,
      tinggiBadan: tinggi,
      pengaliAktivitas: _pengaliAktivitas,
    );

    if (!mounted) return;

    if (result != null) {
      _tampilkanSheetHasil(result);
    } else {
      final errorState = ref.read(nutritionCalculatorControllerProvider);
      final errorMsg = errorState.hasError
          ? errorState.error.toString()
          : 'Gagal menyimpan profil';
      _showFloatingSnackBar(errorMsg);
    }
  }

  void _tampilkanSheetHasil(NutritionCalculationResult result) {
    AppBottomSheet.show(
      context: context,
      title: 'Analisa Kebutuhan Gizi',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalorieSummaryCard(
            statusBmi: result.statusBmi,
            targetKalori: result.targetKalori,
            programName: 'Program: ${result.targetDiet}',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'NutriBox akan otomatis menyesuaikan jadwal dan porsi menu harianmu sesuai target kalori di atas.',
            style: AppTypography.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            text: 'Lihat Paket Langganan',
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PackageSelectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PackageSelectionScreen(),
                  ),
                );
              },
              child: Text(
                'Lewati dulu',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionCalculatorControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Fisik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperHeader(
                currentStep: 0,
                totalSteps: 3,
                title: 'Data Diri & Fisik',
                subtitle:
                    'Isi informasi fisik untuk menghitung kebutuhan kalori harianmu',
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nama Lengkap
                        Text('Nama Lengkap', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _namaController,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Ahmad Fauzi',
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Nama wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Gender (Chips Pilihan)
                        Text('Jenis Kelamin', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            AppChip(
                              label: 'Laki-laki',
                              isSelected: _gender == 'L',
                              leading: const Icon(Icons.male, size: 16),
                              onTap: () => setState(() => _gender = 'L'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppChip(
                              label: 'Perempuan',
                              isSelected: _gender == 'P',
                              leading: const Icon(Icons.female, size: 16),
                              onTap: () => setState(() => _gender = 'P'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Tanggal Lahir
                        Text('Tanggal Lahir', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _tglLahirController,
                          readOnly: true,
                          onTap: _pilihTanggal,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(
                            hintText: 'Pilih tanggal lahir',
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: AppColors.brandGreen,
                            ),
                          ),
                          validator: (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Pilih tanggal lahir!'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Berat & Tinggi Badan
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Berat (kg)', style: AppTypography.label),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _beratController,
                                    style: AppTypography.bodyMd,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '65',
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Wajib diisi';
                                      }
                                      final num = double.tryParse(
                                          val.replaceAll(',', '.'));
                                      if (num == null || num <= 0) {
                                        return 'Tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tinggi (cm)', style: AppTypography.label),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextFormField(
                                    controller: _tinggiController,
                                    style: AppTypography.bodyMd,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '170',
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Wajib diisi';
                                      }
                                      final num = double.tryParse(
                                          val.replaceAll(',', '.'));
                                      if (num == null || num <= 0) {
                                        return 'Tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Aktivitas Harian
                        Text('Aktivitas Harian', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<double>(
                          initialValue: _pengaliAktivitas,
                          isExpanded: true,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(),
                          items: const [
                            DropdownMenuItem(
                              value: 1.2,
                              child: Text('Jarang Olahraga / Kerja Duduk'),
                            ),
                            DropdownMenuItem(
                              value: 1.375,
                              child: Text('Olahraga Ringan (1-3x/minggu)'),
                            ),
                            DropdownMenuItem(
                              value: 1.55,
                              child: Text('Olahraga Sedang (3-5x/minggu)'),
                            ),
                            DropdownMenuItem(
                              value: 1.725,
                              child: Text('Sangat Aktif (Setiap Hari)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _pengaliAktivitas = val);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // CTA Button
                        AppPrimaryButton(
                          text: 'Hitung & Simpan Profil',
                          isLoading: isLoading,
                          onPressed: _hitungDanSimpan,
                        ),
                      ],
                    ),
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
