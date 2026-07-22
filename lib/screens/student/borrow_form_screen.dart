import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/facility.dart';
import '../../providers/loan_provider.dart';
import 'package:intl/intl.dart';

class BorrowFormScreen extends StatefulWidget {
  final Facility facility;

  const BorrowFormScreen({super.key, required this.facility});

  @override
  State<BorrowFormScreen> createState() => _BorrowFormScreenState();
}

class _BorrowFormScreenState extends State<BorrowFormScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _purposeController = TextEditingController();

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          if (isStart) {
            _startDate = dt;
          } else {
            _endDate = dt;
          }
        });
      }
    }
  }

  void _submit() async {
    if (_startDate == null || _endDate == null || _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua bidang!')),
      );
      return;
    }

    final success = await context.read<LoanProvider>().createLoan(
      widget.facility.id,
      _startDate!,
      _endDate!,
      _purposeController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengajukan peminjaman.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Peminjaman')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fasilitas: ${widget.facility.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDateTime(context, true),
                    child: Text(_startDate == null
                        ? 'Pilih Waktu Mulai'
                        : DateFormat('dd/MM/yyyy HH:mm').format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDateTime(context, false),
                    child: Text(_endDate == null
                        ? 'Pilih Waktu Selesai'
                        : DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(labelText: 'Alasan Keperluan'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Ajukan Peminjaman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
