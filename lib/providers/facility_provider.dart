import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/facility.dart';

class FacilityProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<Facility> _facilities = [];
  List<Facility> get facilities => _facilities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchFacilities() async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase.from('facilities').select().order('created_at', ascending: false);
      _facilities = (data as List).map((e) => Facility.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching facilities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFacility(Facility facility) async {
    try {
      final map = facility.toMap();
      map.remove('id');
      map.remove('image_url');
      await _supabase.from('facilities').insert(map);
      await fetchFacilities();
      return true;
    } catch (e) {
      print('Error adding facility: $e');
      return false;
    }
  }

  Future<bool> updateFacility(Facility facility) async {
    try {
      await _supabase.from('facilities').update({
        'name': facility.name,
        'category': facility.category,
        'stock': facility.stock,
        'notes': facility.notes,
        'image_url': facility.imageUrl,
      }).eq('id', facility.id);
      await fetchFacilities();
      return true;
    } catch (e) {
      print('Error updating facility: $e');
      return false;
    }
  }

  Future<bool> deleteFacility(String id) async {
    try {
      await _supabase.from('facilities').delete().eq('id', id);
      await fetchFacilities();
      return true;
    } catch (e) {
      print('Error deleting facility: $e');
      return false;
    }
  }
}
