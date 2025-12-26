// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme.g.dart';

/// Material 3 Theme Configuration for the Maouidi App
///
/// Professional color scheme:
/// - Primary: #11A381 (Teal/Green)
/// - Surface: #1C333C (Dark Blue-Gray)

class AppTheme {
  // Brand Colors (from user design)
  static const Color primaryGreen = Color(0xFF11A381);
  static const Color surfaceDark = Color(0xFF1C333C);

  // Supporting Colors
  static const Color accentAmber = Color(0xFFFFC107); // For ratings
  static const Color errorRed = Color(0xFFEF5350); // For errors/charities

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F4);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);

  /// Dark Theme Configuration (Primary - Professional)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryGreen,
      onPrimary: Colors.white,
      secondary: primaryGreen.withOpacity(0.7),
      onSecondary: Colors.white,
      tertiary: accentAmber,
      onTertiary: Colors.black87,
      error: errorRed,
      onError: Colors.white,
      background: darkBackground,
      onBackground: Colors.white,
      surface: surfaceDark,
      onSurface: Colors.white,
      surfaceVariant: darkSurfaceVariant,
      onSurfaceVariant: Colors.white70,
      outline: Colors.white24,
      outlineVariant: Colors.white12,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,

      // Typography - Inter font for professional look
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
        displayMedium:
            GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall:
            GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge:
            GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium:
            GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall:
            GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge:
            GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium:
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),

      // NavigationBar Theme (Bottom Nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryGreen.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white60,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen);
          }
          return const IconThemeData(color: Colors.white60);
        }),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Colors.white38),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Colors.white12,
        thickness: 1,
        space: 1,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: darkBackground,

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        selectedColor: primaryGreen.withOpacity(0.3),
        deleteIconColor: Colors.white70,
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Light Theme Configuration (Secondary)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryGreen,
      onPrimary: Colors.white,
      secondary: primaryGreen.withOpacity(0.7),
      onSecondary: Colors.white,
      tertiary: accentAmber,
      onTertiary: Colors.black87,
      error: errorRed,
      onError: Colors.white,
      background: lightBackground,
      onBackground: Colors.black87,
      surface: lightSurface,
      onSurface: Colors.black87,
      surfaceVariant: lightSurfaceVariant,
      onSurfaceVariant: Colors.black54,
      outline: Colors.black12,
      outlineVariant: Colors.black.withOpacity(0.05),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,

      // Typography
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: lightSurface,
        surfaceTintColor: Colors.transparent,
      ),

      // NavigationBar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: primaryGreen.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          );
        }),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: lightBackground,
    );
  }
}

/// Theme Mode Provider - manages light/dark theme preference
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.dark; // Default to dark theme to show off brand colors
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
    state = mode;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
