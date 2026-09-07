import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  String _storeName = 'NIS Digital Store';
  String _bannerUrl = '';
  bool _isLoading = false;
  String? _settingsId;

  String get storeName => _storeName;
  String get bannerUrl => _bannerUrl;
  bool get isLoading => _isLoading;

  StoreProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _client
          .from('store_settings')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _settingsId = response['id'];
        _storeName = response['store_name'] ?? 'NIS Digital Store';
        _bannerUrl = response['banner_url'] ?? '';
      } else {
        // Create the singleton row
        final inserted = await _client.from('store_settings').insert({
          'store_name': 'NIS Digital Store',
        }).select().single();
        _settingsId = inserted['id'];
      }
    } catch (e) {
      debugPrint('StoreProvider loadSettings error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStoreName(String newName) async {
    final prev = _storeName;
    _storeName = newName;
    notifyListeners();
    try {
      if (_settingsId != null) {
        await _client
            .from('store_settings')
            .update({'store_name': newName})
            .eq('id', _settingsId!);
      } else {
        final inserted = await _client.from('store_settings').insert({
          'store_name': newName,
        }).select().single();
        _settingsId = inserted['id'];
      }
    } catch (e) {
      _storeName = prev;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBannerUrl(String url) async {
    final prev = _bannerUrl;
    _bannerUrl = url;
    notifyListeners();
    try {
      if (_settingsId != null) {
        await _client
            .from('store_settings')
            .update({'banner_url': url})
            .eq('id', _settingsId!);
      }
    } catch (e) {
      _bannerUrl = prev;
      notifyListeners();
      rethrow;
    }
  }
}
