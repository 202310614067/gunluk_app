import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    final authBox = Hive.box('auth');
    _isDarkMode = authBox.get('isDarkMode', defaultValue: false);
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    Hive.box('auth').put('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
