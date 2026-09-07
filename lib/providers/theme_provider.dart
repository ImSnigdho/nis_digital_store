import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_id';
  String _currentThemeId = 'Light'; 

  String get currentThemeId => _currentThemeId;
  
  // Keep isDarkMode for backwards compatibility with parts of the app that just need a quick dark toggle flag
  bool get isDarkMode => _currentThemeId == 'Dark' || _currentThemeId == 'Midnight' || _currentThemeId == 'Cyberpunk' || _currentThemeId == 'Grey';

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeId = prefs.getString(_themeKey) ?? 'Light';
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    _currentThemeId = themeId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }

  // Deprecated: use setTheme
  Future<void> toggleTheme() async {
    setTheme(isDarkMode ? 'Light' : 'Dark');
  }
}

