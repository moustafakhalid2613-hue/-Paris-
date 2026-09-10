flimport 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/login_screen.dart';
// import 'screens/signup_screen.dart'; // متاحة عبر التنقل من شاشة الدخول
// import 'screens/home_dashboard.dart'; // سيتم إضافتها في خطوة لاحقة

/// ============================================================
///  نقطة الدخول الرئيسية لتطبيق صالون Paris
/// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(
    // عند توليد ملفات الإعداد عبر flutterfire configure
    // سيتم استبدال هذا تلقائياً بـ: options: DefaultFirebaseOptions.currentPlatform
  );

  // إعدادات Firestore (تخزين مؤقت أوفلاين لتحسين الأداء داخل الصالون)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // قراءة تفضيل الثيم المحفوظ مسبقاً
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('paris_dark_mode') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDark),
      child: const ParisSalonApp(),
    ),
  );
}

/// ============================================================
///  إدارة حالة الثيم (ليلي / نهاري) مع حفظ التفضيل
/// ============================================================
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._isDark);

  bool _isDark;
  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paris_dark_mode', _isDark);
  }
}

/// ============================================================
///  الويدجت الجذري للتطبيق
/// ============================================================
class ParisSalonApp extends StatelessWidget {
  const ParisSalonApp({super.key});

  // ---- ألوان هوية صالون Paris ----
  static const Color parisGold = Color(0xFFC9A24B);
  static const Color parisRose = Color(0xFFB76E79);
  static const Color parisDarkBg = Color(0xFF121212);
  static const Color parisLightBg = Color(0xFFFAF7F5);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Paris Salon',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      themeMode: themeProvider.themeMode,

      // ---------------- الثيم النهاري ----------------
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: parisLightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: parisGold,
          brightness: Brightness.light,
          primary: parisGold,
          secondary: parisRose,
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: parisLightBg,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: parisGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),

      // ---------------- الثيم الليلي ----------------
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: parisDarkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: parisGold,
          brightness: Brightness.dark,
          primary: parisGold,
          secondary: parisRose,
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: parisDarkBg,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: parisGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
