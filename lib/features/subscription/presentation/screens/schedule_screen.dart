import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/meal_address_tile.dart';
import '../../../../core/widgets/option_tile.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../../../core/widgets/week_day_chips.dart';
import '../../data/subscription_repository.dart';
import '../../models/address_model.dart';
import '../../models/package_model.dart';
import '../../models/schedule_model.dart';
import 'payment_screen.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final PackageModel selectedPackage;
  final List<AddressModel> addresses;

  const ScheduleScreen({
    super.key,
    required this.selectedPackage,
    required this.addresses,
  });

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String _selectedDay = 'Senin';
  final Map<String, Map<String, AddressModel?>> _jadwalPengiriman = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final defaultAddr = widget.addresses.isNotEmpty ? widget.addresses.first : null;
    for (var h in AppConstants.listHari) {
      _jadwalPengiriman[h] = {};
      for (var w in AppConstants.listWaktuMakan) {
        _jadwalPengiriman[h]![w] = defaultAddr;
      }
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

  void _pilihAlamatViaSheet(String waktuMakan) {
    final currentAddress = _jadwalPengiriman[_selectedDay]?[waktuMakan];

    AppBottomSheet.show(
      context: context,
      title: 'Pilih Alamat $waktuMakan',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.addresses.map((alamat) {
            final isSelected = currentAddress?.id == alamat.id;
            return OptionTile(
              title: alamat.labelAlamat,
              subtitle: alamat.alamatLengkap,
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.brandGreen,
              ),
              selected: isSelected,
              onTap: () {
                setState(() {
                  _jadwalPengiriman[_selectedDay]![waktuMakan] = alamat;
                });
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _simpanJadwal() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (widget.addresses.isEmpty) {
      _showFloatingSnackBar('Tambahkan alamat terlebih dahulu!');
      return;
    }

    final defaultAddr = widget.addresses.first;
    final List<ScheduleItem> itemsToSave = [];

    for (var h in AppConstants.listHari) {
      for (var w in AppConstants.listWaktuMakan) {
        final address = _jadwalPengiriman[h]?[w] ?? defaultAddr;
        itemsToSave.add(ScheduleItem(
          userId: user.id,
          hari: h,
          waktuMakan: w,
          alamatId: address.id,
        ));
      }
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.saveSchedule(
        userId: user.id,
        scheduleItems: itemsToSave,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              selectedPackage: widget.selectedPackage,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showFloatingSnackBar('Gagal menyimpan jadwal: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultAddr = widget.addresses.isNotEmpty
        ? widget.addresses.first
        : const AddressModel(
            id: '',
            userId: '',
            labelAlamat: 'Belum ada alamat',
            alamatLengkap: '-',
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Atur Jadwal Pengiriman'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const StepperHeader(
              currentStep: 1,
              totalSteps: 3,
              title: 'Jadwal Alamat Pengiriman',
              subtitle: 'Tentukan lokasi pengiriman makanan untuk setiap hari',
            ),
            WeekDayChips(
              selectedDay: _selectedDay,
              onDaySelected: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                children: AppConstants.listWaktuMakan.map((waktu) {
                  final address =
                      _jadwalPengiriman[_selectedDay]?[waktu] ?? defaultAddr;

                  return MealAddressTile(
                    waktuMakan: waktu,
                    labelAlamat: address.labelAlamat,
                    alamatLengkap: address.alamatLengkap,
                    onUbahTap: () => _pilihAlamatViaSheet(waktu),
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppShadows.top,
              ),
              child: AppPrimaryButton(
                text: 'Lanjut ke Pembayaran',
                isLoading: _isSaving,
                onPressed: _simpanJadwal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
