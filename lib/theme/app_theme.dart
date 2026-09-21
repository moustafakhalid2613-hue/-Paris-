import 'package:flutter/material.dart';

/// ألوان الهوية: بيبي بلو + أسود
class AppColors {
  static const Color babyBlue = Color(0xFF89CFF0);
  static const Color babyBlueDark = Color(0xFF5FB3E0);
  static const Color babyBlueLight = Color(0xFFC8E9FA);
  static const Color black = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5FBFF),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.babyBlue,
      brightness: Brightness.light,
      primary: AppColors.babyBlue,
      onPrimary: AppColors.black,
      secondary: AppColors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.babyBlue,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.babyBlue,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.babyBlueLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.babyBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.black, width: 1.5),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkSurface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.babyBlue,
      brightness: Brightness.dark,
      primary: AppColors.babyBlueDark,
      onPrimary: AppColors.black,
      secondary: AppColors.babyBlue,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.babyBlue,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.babyBlue,
      foregroundColor: AppColors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.babyBlue,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.babyBlueDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.babyBlue, width: 1.5),
      ),
    ),
  );
}

/// مزوّد بسيط للتحكم في الوضع الليلي/النهاري ويحفظ الاختيار
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
