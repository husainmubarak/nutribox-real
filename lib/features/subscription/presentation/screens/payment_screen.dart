import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../home/data/home_repository.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/subscription_repository.dart';
import '../../models/package_model.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final PackageModel selectedPackage;

  const PaymentScreen({
    super.key,
    required this.selectedPackage,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  String _metodePembayaran = 'Transfer Bank';

  Future<void> _prosesPembayaran() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);

      await repo.createSubscription(
        userId: user.id,
        paketId: widget.selectedPackage.id,
        durasiHari: widget.selectedPackage.durasiHari,
        totalHarga: widget.selectedPackage.harga,
        paymentMethod: _metodePembayaran,
        simulateImmediateActive: true,
      );

      // Refresh data beranda
      ref.invalidate(homeDashboardProvider);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Pesanan Berhasil!', textAlign: TextAlign.center),
            content: const Text(
              'Terima kasih! Jadwal pengiriman makanan sehat Anda sudah kami terima dan paket langganan Anda kini telah aktif.',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: () {
                  // FIX MAJOR BUG: Navigasi kembali ke Beranda (HomeScreen), bukan ke Kalkulator Gizi!
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'KEMBALI KE BERANDA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paket = widget.selectedPackage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            paket.namaPaket,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          'Rp ${paket.harga}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ongkos Kirim', style: TextStyle(fontSize: 16)),
                        Text(
                          'Gratis',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Bayar',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${paket.harga}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: _metodePembayaran,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                  value: 'Transfer Bank',
                  child: Text('Transfer Bank (BCA/Mandiri)'),
                ),
                DropdownMenuItem(
                  value: 'E-Wallet',
                  child: Text('E-Wallet (GoPay/OVO)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _metodePembayaran = val);
              },
            ),

            const Spacer(),

            _isProcessing
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _prosesPembayaran,
                    child: const Text(
                      'BAYAR SEKARANG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
