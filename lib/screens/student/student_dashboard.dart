import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/facility_provider.dart';
import '../../providers/loan_provider.dart';
import '../auth/login_screen.dart';
import 'borrow_form_screen.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacilityProvider>().fetchFacilities();
      context.read<LoanProvider>().fetchLoans(forAdmin: false);
    });
  }

  void _logout() async {
    await context.read<AppAuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dasbor Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _currentIndex == 0 ? const FacilityCatalog() : const LoanHistory(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Katalog'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Peminjaman'),
        ],
      ),
    );
  }
}

class FacilityCatalog extends StatelessWidget {
  const FacilityCatalog({super.key});

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase() == 'ruangan') return Icons.meeting_room;
    if (category.toLowerCase() == 'elektronik') return Icons.devices;
    return Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    final facilityProvider = context.watch<FacilityProvider>();

    if (facilityProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final facilities = facilityProvider.facilities;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: Icon(_getCategoryIcon(facility.category), color: Colors.indigo),
            ),
            title: Text(facility.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Kategori: ${facility.category}\nTersedia: ${facility.stock} unit'),
            ),
            trailing: ElevatedButton(
              onPressed: facility.stock > 0
                  ? () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BorrowFormScreen(facility: facility),
                      ));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Pinjam'),
            ),
          ),
        );
      },
    );
  }
}

class LoanHistory extends StatelessWidget {
  const LoanHistory({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'returned': return Colors.blue;
      case 'verified': return Colors.teal;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    if (loanProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loans = loanProvider.loans;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        loan.facility?.name ?? 'Unknown Facility',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Chip(
                      label: Text(loan.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: _getStatusColor(loan.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${DateFormat('dd MMM HH:mm').format(loan.startDate)} - ${DateFormat('dd MMM HH:mm').format(loan.endDate)}'),
                  ],
                ),
                const SizedBox(height: 16),
                if (loan.status == 'approved')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        loanProvider.updateLoanStatus(loan.id, 'returned');
                      },
                      icon: const Icon(Icons.assignment_return),
                      label: const Text('Kembalikan Barang'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
