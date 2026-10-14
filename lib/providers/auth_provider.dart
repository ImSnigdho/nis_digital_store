import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  User? _user;
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  String get currency => _profile?.currency ?? 'BDT';
  String get country => _profile?.country ?? 'BD';
  bool get isProfileComplete => _profile?.phone != null && _profile?.phone!.isNotEmpty == true;
  bool get isAdmin => _profile?.role == 'admin';

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        loadProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });

    if (_user != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    _profile = await _profileService.getProfile();

    // Default the avatar to the picture from Google OAuth if signed in via Google
    // and profile avatar is not yet set.
    if (_profile != null &&
        (_profile!.avatarUrl == null || _profile!.avatarUrl!.trim().isEmpty)) {
      final userMeta = _user?.userMetadata;
      final googlePhoto = userMeta?['avatar_url'] as String? ??
          userMeta?['picture'] as String?;
      if (googlePhoto != null && googlePhoto.trim().isNotEmpty) {
        try {
          _profile = await _profileService.updateProfile(
            _profile!.copyWith(avatarUrl: googlePhoto.trim()),
          );
        } catch (_) {}
      }
    }

    notifyListeners();
  }

  Future<String> uploadAndSetAvatar(Uint8List bytes, String fileName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final avatarUrl = await _profileService.uploadAvatar(bytes, fileName);
      if (_profile != null) {
        _profile = await _profileService.updateProfile(
          _profile!.copyWith(avatarUrl: avatarUrl),
        );
      }
      return avatarUrl;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        country: country,
      );
      _user = response.user ?? _authService.currentUser;
      if (_user != null) {
        await loadProfile();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.signIn(email: email, password: password);
      _user = response.user ?? _authService.currentUser;
      await loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.signInWithGoogle();
      if (!success) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _user = _authService.currentUser;
      await loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> updateCountry(String country) async {
    await _profileService.updateCountry(country);
    await loadProfile();
  }

  Future<void> updateProfile(Profile profile) async {
    _profile = await _profileService.updateProfile(profile);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

