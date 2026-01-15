import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// BG
// Secondary & White
// Primary
// Black / Primary

enum AppTheme {
  horizonblue,
  evergreen,
  roseglow,
  midnightgold,
  coffee
}

class AppPalette {
  final Color primary;
  final Color secondary;
  final Color bg;
  final Color minimal;
  final Color white;
  final Color black;
  final Color accent;
  final Color theme;
  final Color error;
  final Color success;
  final Color warning;

  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.bg,
    required this.minimal,
    required this.white,
    required this.black,
    required this.accent,
    required this.theme,
    required this.error,
    required this.success,
    required this.warning,
  });
}

const Map<AppTheme, AppPalette> _palettes = {
  AppTheme.horizonblue: AppPalette(
    bg: Color(0xFFF6F1F1),
    secondary: Color(0xFFD3E0EA),
    primary: Color(0xFF004C70),
    minimal: Color(0xFF112D4E),
    accent: Color(0xFFFFFFFF),

    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    
    theme : Color(0xFFFFFFFF),

    error: Color(0xFFB00020),
    success: Color.fromARGB(255, 0, 160, 21),
    warning: Color(0xFFFFAB00),

  ),
  
  // AppTheme.evergreen: AppPalette(
  //   primary: Color(0xFF4C763B),
  //   secondary: Color(0xFFFDFAF6),

  //   bg: Color(0xFFFAF6E9),
  //   minimal: Color(0xFFFAF6E9),
  //   whiteMain: Color(0xFFFAF6E9),

  //   white: Color(0xFFFFFFFF),
  //   black: Color(0xFF000000),

  //   blackMain: Color(0xFF043915),
  //   accent: Color(0xFF043915),

  //   theme : Color(0xFFFFFFFF)

  // ),
  // AppTheme.roseglow: AppPalette(
  //   primary: Color(0xFF4B164C),
  //   secondary: Color(0xFFF8E7F6),

  //   bg: Color(0xFFF5F5F5),
  //   minimal: Color(0xFFF5F5F5),
  //   whiteMain: Color(0xFFF5F5F5),

  //   white: Color(0xFFFFFFFF),
  //   black: Color(0xFF000000),

  //   blackMain: Color(0xFF4B164C),
  //   accent: Color(0xFF4B164C),

  //   theme : Color(0xFFFFFFFF)

  // ),
  // AppTheme.midnightgold: AppPalette(
  //   primary: Color(0xFFFFCB74),
  //   secondary: Color(0xFF2F2F2F),

  //   bg: Color(0xFF131313),
  //   minimal: Color(0xFF2F2F2F),
  //   whiteMain: Color(0xFF131313),

  //   blackMain: Color(0xFFF6F6F6),
  //   accent: Color(0xFFF6F6F6),

  //   theme : Color(0xFF111111)

  // ),

  // AppTheme.coffee: AppPalette(
  //   primary: Color(0xFF74512D),
  //   secondary: Color(0xFFE7D3C0),

  //   bg: Color(0xFFFCF7EF),
  //   minimal: Color(0xFFFCF7EF),
  //   whiteMain: Color(0xFFFCF7EF),

  //   blackMain: Color(0xFF543310),
  //   accent: Color(0xFF543310),

  //   theme : Color(0xFFFFFFFF)

  // ),
};

class ThemeController extends GetxController {
  // ✅ Box is injected from main.dart
  final Box _settingsBox;

  ThemeController(this._settingsBox);

  static const _themeKey = 'selectedTheme';

  final Rx<AppTheme> selectedTheme = AppTheme.horizonblue.obs;

  AppPalette get palette => _palettes[selectedTheme.value]!;

  ThemeData get themeData => _themeFromPalette(palette);

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    final savedIndex =
        _settingsBox.get(_themeKey, defaultValue: AppTheme.horizonblue.index);
    selectedTheme.value = AppTheme.values[savedIndex];
  }

  void changeTheme(AppTheme theme) {
    selectedTheme.value = theme;
    _settingsBox.put(_themeKey, theme.index);
    Get.changeTheme(_themeFromPalette(_palettes[theme]!));
  }

  ThemeData _themeFromPalette(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: scheme.copyWith(
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.bg,
      ),
      scaffoldBackgroundColor: palette.bg,
      primaryColor: palette.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.primary,
        foregroundColor: palette.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
