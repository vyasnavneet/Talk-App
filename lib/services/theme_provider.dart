import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark }

class ThemeNotifier extends StateNotifier<ThemeModeType> {
  ThemeNotifier() : super(ThemeModeType.light) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeModeType.dark : ThemeModeType.light;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == ThemeModeType.light
        ? ThemeModeType.dark
        : ThemeModeType.light;
    await prefs.setBool('isDarkMode', state == ThemeModeType.dark);
  }

  void setTheme(ThemeModeType mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setBool('isDarkMode', state == ThemeModeType.dark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeModeType>((
  ref,
) {
  return ThemeNotifier();
});
