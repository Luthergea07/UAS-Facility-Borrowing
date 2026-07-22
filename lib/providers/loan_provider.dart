import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loan.dart';

class LoanProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<Loan> _loans = [];
  List<Loan> get loans => _loans;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchLoans({bool forAdmin = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      var query = _supabase.from('loans').select('*, profiles(*), facilities(*)');
      
      if (!forAdmin) {
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          query = query.eq('user_id', userId);
        }
      }

      final data = await query.order('created_at', ascending: false);
      _loans = (data as List).map((e) => Loan.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching loans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLoan(String facilityId, DateTime startDate, DateTime endDate, String purpose) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('loans').insert({
        'user_id': userId,
        'facility_id': facilityId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'purpose': purpose,
        'status': 'pending',
      });
      await fetchLoans(forAdmin: false);
      return true;
    } catch (e) {
      print('Error creating loan: $e');
      return false;
    }
  }

  Future<bool> updateLoanStatus(String loanId, String newStatus, {bool isReturn = false}) async {
    try {
      await _supabase.from('loans').update({'status': newStatus}).eq('id', loanId);
      
      // If admin verifies return, we should technically increase stock, but for now 
      // let's just let admin manage stock manually or we do an RPC.
      // A simple way is to fetch facility and update stock here, but better done in Supabase RPC.
      // For simplicity in flutter side without RPC:
      if (newStatus == 'verified') {
        final loan = _loans.firstWhere((l) => l.id == loanId);
        final facility = loan.facility;
        if (facility != null) {
          await _supabase.from('facilities').update({'stock': facility.stock + 1}).eq('id', facility.id);
        }
      } else if (newStatus == 'approved') {
        final loan = _loans.firstWhere((l) => l.id == loanId);
        final facility = loan.facility;
        if (facility != null && facility.stock > 0) {
          await _supabase.from('facilities').update({'stock': facility.stock - 1}).eq('id', facility.id);
        }
      }

      // Refresh list
      final currentUser = _supabase.auth.currentUser;
      final profileData = await _supabase.from('profiles').select('role').eq('id', currentUser!.id).single();
      final isAdmin = profileData['role'] == 'admin';
      
      await fetchLoans(forAdmin: isAdmin);
      return true;
    } catch (e) {
      print('Error updating loan status: $e');
      return false;
    }
  }
}
