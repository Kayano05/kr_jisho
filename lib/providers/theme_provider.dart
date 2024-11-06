import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _backgroundImageKey = 'background_image_path';
  int _selectedTheme = 0;
  String? _backgroundImagePath;

  ThemeProvider() {
    _loadTheme();
    _loadBackgroundImage();
  }

  int get selectedTheme => _selectedTheme;
  String? get backgroundImagePath => _backgroundImagePath;

  Color get backgroundColor {
    switch (_selectedTheme) {
      case 0:
        return Colors.white;
      case 1:
        return Colors.black;
      case 2:
        return Colors.white;
      case 3:
        return Colors.blue.shade50;
      case 4:
        return Colors.pink.shade50;
      default:
        return Colors.white;
    }
  }

  Color get accentColor {
    switch (_selectedTheme) {
      case 0:
      case 1:
      case 2:
        return Colors.amber;
      case 3:
        return Colors.blue.shade600;
      case 4:
        return Colors.pink.shade400;
      default:
        return Colors.amber;
    }
  }

  Color get textColor {
    switch (_selectedTheme) {
      case 0:
      case 2:
        return Colors.black87;
      case 1:
        return Colors.white;
      case 3:
        return Colors.blue.shade900;
      case 4:
        return Colors.pink.shade900;
      default:
        return Colors.black87;
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedTheme = prefs.getInt(_themeKey) ?? 0;
    notifyListeners();
  }

  Future<void> setTheme(int theme) async {
    if (theme == _selectedTheme) return;
    _selectedTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme);
    notifyListeners();
  }

  Future<void> _loadBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    _backgroundImagePath = prefs.getString(_backgroundImageKey);
    notifyListeners();
  }

  Future<void> setBackgroundImage(String? path) async {
    if (path == _backgroundImagePath) return;
    _backgroundImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(_backgroundImageKey, path);
    } else {
      await prefs.remove(_backgroundImageKey);
    }
    notifyListeners();
  }
} 