import 'package:flutter/material.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  // Inicia com o tema claro por padrão
  ThemeService() : super(ThemeMode.light);

  void toggleTheme(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}