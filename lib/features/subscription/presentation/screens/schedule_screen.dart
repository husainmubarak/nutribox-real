import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
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
  final Map<String, Map<String, String?>> _jadwalPengiriman = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (var h in AppConstants.listHari) {
      _jadwalPengiriman[h] = {};
      for (var w in AppConstants.listWaktuMakan) {
        _jadwalPengiriman[h]![w] = null;
      }
    }
  }

  Future<void> _simpanJadwal() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final List<ScheduleItem> itemsToSave = [];

    for (var h in AppConstants.listHari) {
      for (var w in AppConstants.listWaktuMakan) {
        final addressId = _jadwalPengiriman[h]![w];
        if (addressId != null && addressId.isNotEmpty) {
          itemsToSave.add(ScheduleItem(
            userId: user.id,
            hari: h,
            waktuMakan: w,
            alamatId: addressId,
          ));
        }
      }
    }

    if (itemsToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu jadwal pengiriman!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.saveSchedule(
        userId: user.id,
        scheduleItems: itemsToSave,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jadwal berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jadwal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Jadwal Pengiriman'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: AppConstants.listHari.length,
              itemBuilder: (context, index) {
                final hari = AppConstants.listHari[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hari,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Divider(),
                        ...AppConstants.listWaktuMakan.map((waktu) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    waktu,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _jadwalPengiriman[hari]![waktu],
                                    hint: const Text('Pilih Alamat'),
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 0,
                                      ),
                                    ),
                                    items: widget.addresses.map((alamat) {
                                      return DropdownMenuItem<String>(
                                        value: alamat.id,
                                        child: Text(alamat.labelAlamat),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _jadwalPengiriman[hari]![waktu] = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: _isSaving
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _simpanJadwal,
                    child: const Text('SIMPAN JADWAL'),
                  ),
          )
        ],
      ),
    );
  }
}
