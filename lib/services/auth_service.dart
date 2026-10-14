import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String country,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'country': country,
      },
    );
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    }

    try {
      final webClientId = SupabaseConfig.googleWebClientId;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      // Clear any cached account so the Google account selector dialog always opens
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the Google sign-in dialog
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID Token received from Google Sign-In.');
      }

      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return authResponse.session != null || _client.auth.currentUser != null;
    } catch (e) {
      debugPrint('Native Google Sign-In error: $e');
      rethrow;
    }
  }
}

