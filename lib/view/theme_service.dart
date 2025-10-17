import 'package:flutter/material.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  ThemeService() : super(ThemeMode.light);

  void toggleTheme(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}