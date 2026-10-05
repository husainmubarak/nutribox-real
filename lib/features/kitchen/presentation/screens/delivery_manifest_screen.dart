import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/kitchen_repository.dart';
import '../../models/delivery_manifest_item.dart';

class DeliveryManifestScreen extends ConsumerStatefulWidget {
  const DeliveryManifestScreen({super.key});

  @override
  ConsumerState<DeliveryManifestScreen> createState() =>
      _DeliveryManifestScreenState();
}

class _DeliveryManifestScreenState
    extends ConsumerState<DeliveryManifestScreen> {
  String? _updatingKey;

  Future<void> _tandaiDikirim(DeliveryManifestItem item) async {
    final key = "${item.userId}_${item.waktuMakan}";
    setState(() => _updatingKey = key);

    try {
      final repo = ref.read(kitchenRepositoryProvider);
      await repo.markAsDelivered(
        userId: item.userId,
        waktuMakan: item.waktuMakan,
        alamatId: item.alamatId,
      );

      // Refresh data manifest dan dasbor secara reaktif
      ref.invalidate(deliveryManifestProvider);
      ref.invalidate(kitchenDashboardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status pengiriman diubah ke Dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manifestAsync = ref.watch(deliveryManifestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengiriman'),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: manifestAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 10),
                Text('Gagal memuat manifest: $err', textAlign: TextAlign.center),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => ref.invalidate(deliveryManifestProvider),
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (daftarKirim) {
          if (daftarKirim.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(deliveryManifestProvider);
                await ref.read(deliveryManifestProvider.future);
              },
              color: Colors.orange,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('Tidak ada jadwal pengiriman hari ini.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(deliveryManifestProvider);
              await ref.read(deliveryManifestProvider.future);
            },
            color: Colors.orange,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(15),
              itemCount: daftarKirim.length,
              itemBuilder: (context, index) {
                final item = daftarKirim[index];
                final key = "${item.userId}_${item.waktuMakan}";
                final isUpdating = _updatingKey == key;
                final bool sudahDikirim = item.isDelivered;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.namaUser,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sudahDikirim
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                sudahDikirim ? 'DIKIRIM ✓' : 'DIMASAK',
                                style: TextStyle(
                                  color: sudahDikirim ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // FIX: Format string yang benar
                        Text(
                          'Paket: ${item.targetDiet} | Sesi: ${item.waktuMakan}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.red),
                            const SizedBox(width: 5),
                            // FIX: Format teks alamat yang benar dan rapi
                            Expanded(
                              child: Text(
                                '${item.labelAlamat} - ${item.alamatLengkap}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sudahDikirim ? Colors.grey : Colors.green,
                            ),
                            onPressed: (sudahDikirim || isUpdating)
                                ? null
                                : () => _tandaiDikirim(item),
                            child: isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    sudahDikirim ? 'Selesai' : 'Tandai Dikirim',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
