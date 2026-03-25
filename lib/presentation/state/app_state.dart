import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  static const String _themeModeKey = 'app_theme_mode';
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    final saved = (_prefs?.getString(_themeModeKey) ?? '').trim();
    themeMode.value = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  static Future<void> toggleTheme() async {
    final nextMode = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_themeModeKey, mode.name);
  }

  static bool get isDark => themeMode.value == ThemeMode.dark;
}
