import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreProvider extends ChangeNotifier {
  String _storeName = 'NIS Digital Store';
  
  String get storeName => _storeName;

  StoreProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _storeName = prefs.getString('storeName') ?? 'NIS Digital Store';
    notifyListeners();
  }

  Future<void> updateStoreName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('storeName', newName);
    _storeName = newName;
    notifyListeners();
  }
}
