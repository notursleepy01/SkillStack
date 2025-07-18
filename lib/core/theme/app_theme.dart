// lib/core/theme/app_theme.dart
import 'package:dynamic_color/dynamic_color.dart'; // <--- ADDED THIS IMPORT
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(ColorScheme? lightDynamic) {
    ColorScheme lightColorScheme;
    if (lightDynamic != null) {
      lightColorScheme = lightDynamic.harmonized(); // This will now be recognized
    } else {
      lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme(ColorScheme? darkDynamic) {
    ColorScheme darkColorScheme;
    if (darkDynamic != null) {
      darkColorScheme = darkDynamic.harmonized(); // This will now be recognized
    } else {
      darkColorScheme = ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      );
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
