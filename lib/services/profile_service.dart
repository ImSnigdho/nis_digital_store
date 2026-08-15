import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Profile?> getProfile() async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', _userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    final response = await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', _userId)
        .select()
        .single();

    return Profile.fromJson(response);
  }

  Future<void> updateCountry(String country) async {
    final currency = country == 'BD' ? 'BDT' : 'USD';
    await _client
        .from('profiles')
        .update({
          'country': country,
          'currency': currency,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', _userId);
  }
}
