import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
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

  Future<void> _simpanMenu() async {
    final namaMenu = _namaMenuController.text.trim();
    if (namaMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama menu tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan menu: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Menu Hari Ini'),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Target Diet', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              initialValue: _targetDietTerpilih,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: AppConstants.listPilihanDiet.map((diet) {
                return DropdownMenuItem(value: diet, child: Text(diet));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _targetDietTerpilih = val);
              },
            ),
            const SizedBox(height: 20),

            const Text('Waktu Makan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              initialValue: _waktuMakanTerpilih,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: AppConstants.listWaktuMakan.map((waktu) {
                return DropdownMenuItem(value: waktu, child: Text(waktu));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _waktuMakanTerpilih = val);
              },
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _namaMenuController,
              decoration: const InputDecoration(
                labelText: 'Nama Menu (Cth: Ayam Bakar)',
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Singkat',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            _isProcessing
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _simpanMenu,
                    child: const Text(
                      'SIMPAN MENU',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
