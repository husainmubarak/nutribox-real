import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/kitchen_repository.dart';
import '../../models/daily_menu_model.dart';

class MenuInputScreen extends ConsumerStatefulWidget {
  const MenuInputScreen({super.key});

  @override
  ConsumerState<MenuInputScreen> createState() => _MenuInputScreenState();
}

class _MenuInputScreenState extends ConsumerState<MenuInputScreen> {
  late final TextEditingController _namaMenuController;
  late final TextEditingController _deskripsiController;

  bool _isProcessing = false;
  String _targetDietTerpilih = AppConstants.dietBulking;
  String _waktuMakanTerpilih = AppConstants.mealSarapan;

  @override
  void initState() {
    super.initState();
    _namaMenuController = TextEditingController();
    _deskripsiController = TextEditingController();
  }

  @override
  void dispose() {
    _namaMenuController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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

  Future<void> _simpanMenu() async {
    final namaMenu = _namaMenuController.text.trim();
    if (namaMenu.isEmpty) {
      _showFloatingSnackBar('Nama menu tidak boleh kosong!');
      return;
    }

    setState(() => _isProcessing = true);
    FocusScope.of(context).unfocus();

    try {
      final tanggalHariIni = DateFormatter.toIsoDateString();
      final repo = ref.read(kitchenRepositoryProvider);

      await repo.saveDailyMenu(
        DailyMenuModel(
          tanggal: tanggalHariIni,
          targetDiet: _targetDietTerpilih,
          waktuMakan: _waktuMakanTerpilih,
          namaMenu: namaMenu,
          deskripsi: _deskripsiController.text.trim(),
        ),
      );

      if (mounted) {
        _showFloatingSnackBar('Menu sehat harian berhasil disimpan!', isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showFloatingSnackBar('Gagal menyimpan menu: $e');
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Input Menu Harian'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Program Diet', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: _targetDietTerpilih,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(),
                      items: AppConstants.listPilihanDiet.map((diet) {
                        return DropdownMenuItem(value: diet, child: Text(diet));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _targetDietTerpilih = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text('Waktu Makan', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: _waktuMakanTerpilih,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(),
                      items: AppConstants.listWaktuMakan.map((waktu) {
                        return DropdownMenuItem(value: waktu, child: Text(waktu));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _waktuMakanTerpilih = val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text('Nama Menu Masakan', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _namaMenuController,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Salmon Panggang Lemon Herb',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text('Deskripsi & Kandungan Gizi (Opsional)', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _deskripsiController,
                      style: AppTypography.bodyMd,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Dilengkapi sayuran brokoli kukus dan nasi merah organik...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    AppPrimaryButton(
                      text: 'Simpan Menu Hari Ini',
                      isLoading: _isProcessing,
                      onPressed: _simpanMenu,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
