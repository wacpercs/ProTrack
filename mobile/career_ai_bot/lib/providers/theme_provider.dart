import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode => ThemeMode.dark;

  ThemeData get themeData => _darkTheme;

  static final _darkTheme = ThemeData(
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

  bool get isDarkMode => true;

  // No-op: theme is always dark
  void toggleTheme() {}
}
