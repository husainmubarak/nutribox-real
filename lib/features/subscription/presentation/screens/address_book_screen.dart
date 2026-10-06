import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_chip.dart';
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

class AddressBookScreen extends ConsumerStatefulWidget {
  final PackageModel? selectedPackage;

  const AddressBookScreen({
    super.key,
    this.selectedPackage,
  });

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  String _selectedDay = 'Senin';
  bool _samakanSemuaHari = false;
  bool _isSaving = false;

  // Struktur jadwal: Map<Hari, Map<WaktuMakan, AddressModel?>>
  final Map<String, Map<String, AddressModel?>> _jadwalAlamat = {};

  final _labelBaruController = TextEditingController();
  final _detailBaruController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var h in AppConstants.listHari) {
      _jadwalAlamat[h] = {};
      for (var w in AppConstants.listWaktuMakan) {
        _jadwalAlamat[h]![w] = null;
      }
    }
  }

  @override
  void dispose() {
    _labelBaruController.dispose();
    _detailBaruController.dispose();
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

  void _pilihAlamatViaSheet(String waktuMakan, List<AddressModel> addresses) {
    final currentAddress = _jadwalAlamat[_selectedDay]?[waktuMakan];

    AppBottomSheet.show(
      context: context,
      title: 'Pilih Alamat $waktuMakan',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Belum ada alamat tersimpan. Silakan tambah alamat baru.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm,
              ),
            )
          else
            ...addresses.map((alamat) {
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
                    if (_samakanSemuaHari) {
                      for (var h in AppConstants.listHari) {
                        _jadwalAlamat[h]![waktuMakan] = alamat;
                      }
                    } else {
                      _jadwalAlamat[_selectedDay]![waktuMakan] = alamat;
                    }
                  });
                  Navigator.pop(context);
                },
              );
            }),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandGreen,
              side: const BorderSide(color: AppColors.brandGreen),
              shape: const StadiumBorder(),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              Navigator.pop(context);
              _tampilkanSheetTambahAlamat();
            },
            icon: const Icon(Icons.add),
            label: const Text('+ Tambah Alamat Baru'),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _tampilkanSheetTambahAlamat() {
    _labelBaruController.clear();
    _detailBaruController.clear();

    AppBottomSheet.show(
      context: context,
      title: 'Tambah Alamat Baru',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Label Alamat', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _labelBaruController,
            style: AppTypography.bodyMd,
            decoration: const InputDecoration(
              hintText: 'Contoh: Rumah, Kantor, Kos',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Alamat Lengkap', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _detailBaruController,
            style: AppTypography.bodyMd,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nama jalan, nomor rumah, RT/RW, patokan',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            text: 'Simpan Alamat',
            onPressed: () async {
              final label = _labelBaruController.text.trim();
              final detail = _detailBaruController.text.trim();
              if (label.isEmpty || detail.isEmpty) {
                _showFloatingSnackBar('Label dan alamat lengkap wajib diisi!');
                return;
              }
              final user = ref.read(currentUserProvider);
              if (user == null) return;

              try {
                final repo = ref.read(subscriptionRepositoryProvider);
                await repo.addAddress(
                  userId: user.id,
                  labelAlamat: label,
                  alamatLengkap: detail,
                );
                ref.invalidate(addressesFutureProvider);
                if (mounted) {
                  Navigator.pop(context);
                  _showFloatingSnackBar('Alamat baru berhasil ditambahkan!', isError: false);
                }
              } catch (e) {
                _showFloatingSnackBar('Gagal menambah alamat: $e');
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _simpanDanLanjut(List<AddressModel> addresses) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Pastikan setiap waktu makan di setiap hari memiliki alamat (gunakan default alamat pertama jika belum diset)
    if (addresses.isEmpty) {
      _showFloatingSnackBar('Tambahkan minimal satu alamat terlebih dahulu!');
      return;
    }

    final defaultAddress = addresses.first;
    final List<ScheduleItem> itemsToSave = [];

    for (var h in AppConstants.listHari) {
      for (var w in AppConstants.listWaktuMakan) {
        final address = _jadwalAlamat[h]?[w] ?? defaultAddress;
        itemsToSave.add(
          ScheduleItem(
            userId: user.id,
            hari: h,
            waktuMakan: w,
            alamatId: address.id,
          ),
        );
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
        if (widget.selectedPackage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                selectedPackage: widget.selectedPackage!,
              ),
            ),
          );
        } else {
          _showFloatingSnackBar('Pengaturan alamat berhasil disimpan!', isError: false);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showFloatingSnackBar('Gagal menyimpan jadwal alamat: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alamat Pengiriman'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            StepperHeader(
              currentStep: widget.selectedPackage != null ? 1 : 0,
              totalSteps: widget.selectedPackage != null ? 3 : 1,
              title: 'Atur Alamat per Waktu Makan',
              subtitle: 'Katering dapat dikirim ke lokasi berbeda tiap waktu makan',
            ),

            // Toggle "Samakan semua hari"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  AppChip(
                    label: 'Samakan Semua Hari',
                    isSelected: _samakanSemuaHari,
                    leading: Icon(
                      _samakanSemuaHari
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: _samakanSemuaHari
                          ? AppColors.surface
                          : AppColors.textSecondary,
                    ),
                    onTap: () {
                      setState(() {
                        _samakanSemuaHari = !_samakanSemuaHari;
                        if (_samakanSemuaHari) {
                          // Copy jadwal dari selectedDay ke semua hari
                          for (var h in AppConstants.listHari) {
                            for (var w in AppConstants.listWaktuMakan) {
                              _jadwalAlamat[h]![w] =
                                  _jadwalAlamat[_selectedDay]![w];
                            }
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // WeekDayChips
            WeekDayChips(
              selectedDay: _selectedDay,
              onDaySelected: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: AppSpacing.md),

            // List 3 MealAddressTile
            Expanded(
              child: addressesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandGreen,
                    strokeWidth: 3,
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Gagal memuat alamat: $err',
                    style: AppTypography.bodyMd,
                  ),
                ),
                data: (addresses) {
                  final defaultAlamat = addresses.isNotEmpty
                      ? addresses.first
                      : const AddressModel(
                          id: '',
                          userId: '',
                          labelAlamat: 'Belum ada alamat',
                          alamatLengkap: 'Ketuk Ubah untuk menambah alamat',
                        );

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    children: AppConstants.listWaktuMakan.map((waktu) {
                      final alamat =
                          _jadwalAlamat[_selectedDay]?[waktu] ?? defaultAlamat;

                      return MealAddressTile(
                        waktuMakan: waktu,
                        labelAlamat: alamat.labelAlamat,
                        alamatLengkap: alamat.alamatLengkap,
                        onUbahTap: () =>
                            _pilihAlamatViaSheet(waktu, addresses),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // CTA Bawah
            Container(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppShadows.top,
              ),
              child: addressesAsync.when(
                loading: () => const SizedBox(height: 52),
                error: (_, _) => const SizedBox(height: 52),
                data: (addresses) {
                  return AppPrimaryButton(
                    text: widget.selectedPackage != null
                        ? 'Lanjut ke Pembayaran'
                        : 'Simpan Alamat',
                    isLoading: _isSaving,
                    onPressed: () => _simpanDanLanjut(addresses),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
