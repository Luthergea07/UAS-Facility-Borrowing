import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/facility_provider.dart';
import '../../providers/loan_provider.dart';
import '../auth/login_screen.dart';
import 'facility_form_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacilityProvider>().fetchFacilities();
      context.read<LoanProvider>().fetchLoans(forAdmin: true);
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
        title: const Text('Dasbor Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventaris'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Persetujuan'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Verifikasi'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FacilityFormScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const AdminInventory();
      case 1:
        return const AdminApproval();
      case 2:
        return const AdminVerification();
      default:
        return const AdminInventory();
    }
  }
}

class AdminInventory extends StatelessWidget {
  const AdminInventory({super.key});

  IconData _getCategoryIcon(String category) {
    if (category.toLowerCase() == 'ruangan') return Icons.meeting_room;
    if (category.toLowerCase() == 'elektronik') return Icons.devices;
    return Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    final facilityProvider = context.watch<FacilityProvider>();

    if (facilityProvider.isLoading) return const Center(child: CircularProgressIndicator());

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
            title: Text(facility.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Kategori: ${facility.category}\nStok: ${facility.stock}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FacilityFormScreen(facility: facility)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => facilityProvider.deleteFacility(facility.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdminApproval extends StatelessWidget {
  const AdminApproval({super.key});

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    if (loanProvider.isLoading) return const Center(child: CircularProgressIndicator());

    // Tampilkan pending, approved, dan rejected
    final approvalLoans = loanProvider.loans
        .where((l) => ['pending', 'approved', 'rejected'].contains(l.status))
        .toList();

    if (approvalLoans.isEmpty) {
      return const Center(child: Text('Tidak ada riwayat persetujuan', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: approvalLoans.length,
      itemBuilder: (context, index) {
        final loan = approvalLoans[index];
        
        Color statusColor;
        if (loan.status == 'approved') statusColor = Colors.green;
        else if (loan.status == 'rejected') statusColor = Colors.red;
        else statusColor = Colors.orange;

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
                        loan.profile?.fullName ?? 'Mahasiswa',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Chip(
                      label: Text(loan.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: statusColor,
                    ),
                  ],
                ),
                const Divider(),
                Text('Barang: ${loan.facility?.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Tujuan: ${loan.purpose}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${DateFormat('dd MMM HH:mm').format(loan.startDate)} - ${DateFormat('dd MMM HH:mm').format(loan.endDate)}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                
                if (loan.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => loanProvider.updateLoanStatus(loan.id, 'rejected'),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => loanProvider.updateLoanStatus(loan.id, 'approved'),
                        icon: const Icon(Icons.check),
                        label: const Text('Setujui'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdminVerification extends StatelessWidget {
  const AdminVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    if (loanProvider.isLoading) return const Center(child: CircularProgressIndicator());

    final verificationLoans = loanProvider.loans
        .where((l) => ['returned', 'verified'].contains(l.status))
        .toList();

    if (verificationLoans.isEmpty) {
      return const Center(child: Text('Tidak ada riwayat verifikasi', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: verificationLoans.length,
      itemBuilder: (context, index) {
        final loan = verificationLoans[index];
        final isVerified = loan.status == 'verified';

        return Card(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: isVerified ? 16 : 0),
                leading: CircleAvatar(
                  backgroundColor: isVerified ? Colors.teal : Colors.blue,
                  child: Icon(isVerified ? Icons.check_circle : Icons.assignment_return, color: Colors.white),
                ),
                title: Text(loan.facility?.name ?? 'Barang', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Dikembalikan oleh: ${loan.profile?.fullName}'),
                ),
                trailing: isVerified
                    ? const Chip(
                        label: Text('TERVERIFIKASI', style: TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.teal,
                      )
                    : null,
              ),
              if (!isVerified)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => loanProvider.updateLoanStatus(loan.id, 'verified'),
                        icon: const Icon(Icons.verified),
                        label: const Text('Verifikasi (+1 Stok)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
