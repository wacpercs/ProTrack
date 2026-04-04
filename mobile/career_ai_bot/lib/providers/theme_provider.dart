import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  String _currentTheme = 'breaking'; // 'breaking' or 'emo'

  ThemeProvider() {
    _loadTheme();
  }

  String get currentTheme => _currentTheme;
  bool get isEmo => _currentTheme == 'emo';
  ThemeMode get themeMode => ThemeMode.dark;
  bool get isDarkMode => true;

  ThemeData get themeData => _currentTheme == 'emo' ? _emoTheme : _breakingTheme;

  // Accent colors for use in custom widgets
  Color get accentColor => isEmo ? const Color(0xFFFF2D6F) : const Color(0xFF00C853);
  Color get accentColorDark => isEmo ? const Color(0xFFCC1050) : const Color(0xFF00A844);
  Color get secondaryAccent => isEmo ? const Color(0xFFFF69B4) : const Color(0xFFFFD600);

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = prefs.getString('app_theme') ?? 'breaking';
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    if (theme != 'breaking' && theme != 'emo') return;
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme);
    notifyListeners();
  }

  void toggleTheme() {
    setTheme(_currentTheme == 'breaking' ? 'emo' : 'breaking');
  }

  // ═══════════════════════════════════════
  // BREAKING BAD THEME (green/dark)
  // ═══════════════════════════════════════

  static final _breakingTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00C853),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    cardColor: const Color(0xFF252525),
    fontFamily: 'Courier',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Courier',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      displayMedium: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      displaySmall: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      headlineLarge: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      headlineMedium: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      headlineSmall: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      titleLarge: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      titleMedium: TextStyle(color: Color(0xFFE0E0E0), fontFamily: 'Courier'),
      titleSmall: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Courier'),
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0), fontFamily: 'Courier'),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Courier'),
      bodySmall: TextStyle(color: Color(0xFF9E9E9E), fontFamily: 'Courier'),
      labelLarge: TextStyle(color: Colors.white, fontFamily: 'Courier'),
      labelMedium: TextStyle(color: Color(0xFFE0E0E0), fontFamily: 'Courier'),
      labelSmall: TextStyle(color: Color(0xFF9E9E9E), fontFamily: 'Courier'),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF252525),
      hintStyle: const TextStyle(color: Color(0xFF757575), fontFamily: 'Courier'),
      labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontFamily: 'Courier'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: const Color(0xFF1A1A1A),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: Color(0xFF00C853),
      unselectedItemColor: Color(0xFF757575),
      selectedLabelStyle: TextStyle(fontFamily: 'Courier', fontSize: 11),
      unselectedLabelStyle: TextStyle(fontFamily: 'Courier', fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF252525),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00C853),
      secondary: Color(0xFFFFD600),
      surface: Color(0xFF252525),
      onPrimary: Color(0xFF1A1A1A),
      onSecondary: Color(0xFF1A1A1A),
      onSurface: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF252525),
      contentTextStyle: TextStyle(color: Color(0xFF00C853), fontFamily: 'Courier'),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF252525),
      titleTextStyle: TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.w700),
      contentTextStyle: TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Courier', fontSize: 14),
    ),
  );

  // ═══════════════════════════════════════
  // EMO THEME (pink/dark)
  // ═══════════════════════════════════════

  static final _emoTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF2D6F),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    cardColor: const Color(0xFF1A1018),
    fontFamily: 'Courier',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D0D0D),
      foregroundColor: Color(0xFFC9C9C9),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Courier',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFC9C9C9),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      displayMedium: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      displaySmall: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      headlineLarge: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      headlineMedium: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      headlineSmall: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      titleLarge: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      titleMedium: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Courier'),
      titleSmall: TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'Courier'),
      bodyLarge: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Courier'),
      bodyMedium: TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'Courier'),
      bodySmall: TextStyle(color: Color(0xFF666666), fontFamily: 'Courier'),
      labelLarge: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier'),
      labelMedium: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Courier'),
      labelSmall: TextStyle(color: Color(0xFF666666), fontFamily: 'Courier'),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF2D6F), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF1A1018),
      hintStyle: const TextStyle(color: Color(0xFF555555), fontFamily: 'Courier'),
      labelStyle: const TextStyle(color: Color(0xFF777777), fontFamily: 'Courier'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF2D6F),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0D0D0D),
      selectedItemColor: Color(0xFFFF2D6F),
      unselectedItemColor: Color(0xFF555555),
      selectedLabelStyle: TextStyle(fontFamily: 'Courier', fontSize: 11),
      unselectedLabelStyle: TextStyle(fontFamily: 'Courier', fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1A1018),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF2D6F),
      secondary: Color(0xFFFF69B4),
      surface: Color(0xFF1A1018),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF0D0D0D),
      onSurface: Color(0xFFC9C9C9),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF1A1018),
      contentTextStyle: TextStyle(color: Color(0xFFFF2D6F), fontFamily: 'Courier'),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1A1018),
      titleTextStyle: TextStyle(color: Color(0xFFC9C9C9), fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.w700),
      contentTextStyle: TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'Courier', fontSize: 14),
    ),
  );
}
