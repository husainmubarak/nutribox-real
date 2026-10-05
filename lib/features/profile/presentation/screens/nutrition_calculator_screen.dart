import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
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
    );

    if (picked != null && mounted) {
      setState(() {
        _tanggalLahir = picked;
        _tglLahirController.text = DateFormatter.toIsoDateString(picked);
        _umur = DateFormatter.calculateAge(picked, now);
      });
    }
  }

  Future<void> _hitungDanSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final berat = double.tryParse(_beratController.text.trim().replaceAll(',', '.')) ?? 65.0;
    final tinggi = double.tryParse(_tinggiController.text.trim().replaceAll(',', '.')) ?? 170.0;

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
      _tampilkanPopUpHasil(result);
    } else {
      final errorState = ref.read(nutritionCalculatorControllerProvider);
      final errorMsg = errorState.hasError ? errorState.error.toString() : 'Gagal menyimpan profil';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  void _tampilkanPopUpHasil(NutritionCalculationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Analisa Kebutuhan Gizi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Status Tubuh: ${result.statusBmi}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Program: ${result.targetDiet}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Target Kalori Harian:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '${result.targetKalori} Kkal',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kami menyusun menu otomatis sesuai data di atas!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size.fromHeight(45),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PackageSelectionScreen(),
                ),
              );
            },
            child: const Text(
              'LANJUT PILIH PAKET',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionCalculatorControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Fisik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _tglLahirController,
                readOnly: true,
                onTap: _pilihTanggal,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir',
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.green),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Pilih tanggal lahir!' : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: _gender,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _gender = val);
                },
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _beratController,
                      decoration: const InputDecoration(labelText: 'Berat (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        final num = double.tryParse(val.replaceAll(',', '.'));
                        if (num == null || num <= 0) return 'Tidak valid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _tinggiController,
                      decoration: const InputDecoration(labelText: 'Tinggi (cm)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        final num = double.tryParse(val.replaceAll(',', '.'));
                        if (num == null || num <= 0) return 'Tidak valid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<double>(
                initialValue: _pengaliAktivitas,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Aktivitas Harian'),
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
                    child: Text('Sangat Aktif (Tiap Hari)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _pengaliAktivitas = val);
                },
              ),
              const SizedBox(height: 25),

              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _hitungDanSimpan,
                      child: const Text(
                        'HITUNG & SIMPAN PROFIL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
