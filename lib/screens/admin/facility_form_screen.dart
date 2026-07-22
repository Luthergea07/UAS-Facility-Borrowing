import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/facility.dart';
import '../../providers/facility_provider.dart';

class FacilityFormScreen extends StatefulWidget {
  final Facility? facility;
  const FacilityFormScreen({super.key, this.facility});

  @override
  State<FacilityFormScreen> createState() => _FacilityFormScreenState();
}

class _FacilityFormScreenState extends State<FacilityFormScreen> {
  final _nameController = TextEditingController();
  String _category = 'Alat';
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _categories = ['Alat', 'Ruangan', 'Elektronik'];

  @override
  void initState() {
    super.initState();
    if (widget.facility != null) {
      _nameController.text = widget.facility!.name;
      if (_categories.contains(widget.facility!.category)) {
        _category = widget.facility!.category;
      }
      _stockController.text = widget.facility!.stock.toString();
      _notesController.text = widget.facility!.notes ?? '';
    }
  }

  void _submit() async {
    if (_nameController.text.isEmpty || _stockController.text.isEmpty) {
      return;
    }

    final newFacility = Facility(
      id: widget.facility?.id ?? '', // Use existing id if updating
      name: _nameController.text,
      category: _category,
      stock: int.tryParse(_stockController.text) ?? 1,
      notes: _notesController.text,
    );

    final provider = context.read<FacilityProvider>();
    final success = widget.facility == null 
        ? await provider.addFacility(newFacility)
        : await provider.updateFacility(newFacility);

    if (!mounted) return;
    
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.facility == null ? 'Gagal menambah fasilitas.' : 'Gagal memperbarui fasilitas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Fasilitas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Fasilitas'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Stok'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Catatan/Spek'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Simpan Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
