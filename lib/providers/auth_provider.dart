import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AppAuthProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  Profile? _profile;
  Profile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppAuthProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await fetchProfile(user.id);
    }
  }

  Future<void> fetchProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
          
      _profile = Profile.fromMap(data);
    } catch (e) {
      print('Error fetching profile: $e');
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await fetchProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'user', // Default role is user
        }
      );

      return response.user != null;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _profile = null;
    notifyListeners();
  }
}
