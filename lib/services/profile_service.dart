import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<Profile?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return Profile.fromJson(response);
      }

      // If no profile exists yet in the DB (e.g. brand new Google Sign-in user),
      // create and insert the default profile automatically.
      final meta = user.userMetadata ?? {};
      final initialProfile = Profile(
        id: user.id,
        fullName: (meta['full_name'] as String?) ??
            (meta['name'] as String?) ??
            '',
        avatarUrl: (meta['avatar_url'] as String?) ??
            (meta['picture'] as String?),
        country: 'BD',
        currency: 'BDT',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        final inserted = await _client
            .from('profiles')
            .upsert(initialProfile.toJson()..['id'] = user.id)
            .select()
            .single();
        return Profile.fromJson(inserted);
      } catch (_) {
        return initialProfile;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    final json = profile.toJson();
    json['id'] = profile.id;
    json['updated_at'] = DateTime.now().toIso8601String();

    final response = await _client
        .from('profiles')
        .upsert(json)
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

  Future<String> uploadAvatar(Uint8List bytes, String fileName) async {
    final ext =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final path =
        '$_userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: true,
          ),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }
}

