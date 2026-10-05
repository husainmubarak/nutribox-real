import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/subscription_repository.dart';
import '../../models/package_model.dart';
import 'schedule_screen.dart';

class AddressBookScreen extends ConsumerStatefulWidget {
  final PackageModel selectedPackage;

  const AddressBookScreen({
    super.key,
    required this.selectedPackage,
  });

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  late final TextEditingController _labelController;
  late final TextEditingController _detailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _detailController = TextEditingController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _simpanAlamat() async {
    final label = _labelController.text.trim();
    final detail = _detailController.text.trim();

    if (label.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Label dan Detail Alamat wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.addAddress(
        userId: user.id,
        labelAlamat: label,
        alamatLengkap: detail,
      );

      _labelController.clear();
      _detailController.clear();

      // Refresh list alamat secara reaktif via Riverpod
      ref.invalidate(addressesFutureProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alamat berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan alamat: $e'),
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
    final addressesAsync = ref.watch(addressesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Alamat Pengiriman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tambah Alamat Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label (Contoh: Rumah, Kantor)',
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _detailController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
              ),
            ),
            const SizedBox(height: 15),
            _isSaving
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _simpanAlamat,
                    child: const Text('SIMPAN ALAMAT'),
                  ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(thickness: 2),
            ),

            const Text(
              'Alamat Tersimpan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            addressesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Gagal memuat alamat: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (daftarAlamat) {
                if (daftarAlamat.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Belum ada alamat yang disimpan.'),
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daftarAlamat.length,
                      itemBuilder: (context, index) {
                        final alamat = daftarAlamat[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: Text(
                              alamat.labelAlamat,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(alamat.alamatLengkap),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleScreen(
                              selectedPackage: widget.selectedPackage,
                              addresses: daftarAlamat,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'LANJUT ATUR JADWAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
