import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../home/data/home_repository.dart';
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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

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

  Widget _buildQuickDateChip(String label, DateTime targetDate) {
    final isSelected = _selectedDate.year == targetDate.year &&
        _selectedDate.month == targetDate.month &&
        _selectedDate.day == targetDate.day;

    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.bodySm.copyWith(
        color: isSelected ? AppColors.brandGreen : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: isSelected ? AppColors.brandGreenSoft : AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.brandGreen : AppColors.divider,
      ),
      onPressed: () {
        setState(() => _selectedDate = targetDate);
      },
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
      final tanggalStr = DateFormatter.toIsoDateString(_selectedDate);
      final repo = ref.read(kitchenRepositoryProvider);

      await repo.saveDailyMenu(
        DailyMenuModel(
          tanggal: tanggalStr,
          targetDiet: _targetDietTerpilih,
          waktuMakan: _waktuMakanTerpilih,
          namaMenu: namaMenu,
          deskripsi: _deskripsiController.text.trim(),
        ),
      );

      // Invalidate providers agar data beranda & jadwal pelanggan langsung terupdate
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(weeklyScheduleProvider);

      if (mounted) {
        _showFloatingSnackBar(
          'Menu untuk ${DateFormatter.getTodayIndonesianDayName(_selectedDate)}, ${DateFormatter.formatIndonesianDate(tanggalStr)} berhasil disimpan!',
          isError: false,
        );
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
    final formattedDateStr =
        '${DateFormatter.getTodayIndonesianDayName(_selectedDate)}, ${DateFormatter.formatIndonesianDate(DateFormatter.toIsoDateString(_selectedDate))}';

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
                    // Pilihan Tanggal
                    Text('Tanggal Menu', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 7)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.brandGreen,
                                  onPrimary: AppColors.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.brandGreen,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                formattedDateStr,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickDateChip('Hari Ini', DateTime.now()),
                          const SizedBox(width: AppSpacing.xs),
                          _buildQuickDateChip(
                            'Besok (H-1 / H+1)',
                            DateTime.now().add(const Duration(days: 1)),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _buildQuickDateChip(
                            'Lusa (H+2)',
                            DateTime.now().add(const Duration(days: 2)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

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
                      text:
                          'Simpan Menu (${DateFormatter.getTodayIndonesianDayName(_selectedDate)})',
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
