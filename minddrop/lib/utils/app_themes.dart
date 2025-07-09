import 'package:flutter/material.dart';

class AppThemes {
  // Define a seed color for the color scheme
  static const Color _seedColor = Colors.blue; // Or any other brand color

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true, // Recommended for modern Flutter apps
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // Further customizations can be added here:
    // appBarTheme: AppBarTheme( ... ),
    // textTheme: TextTheme( ... ),
    // cardTheme: CardTheme ( ... ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      // Optionally, specify different primary/secondary for dark theme if needed
      // primary: Colors.lightBlue, // Example
    ),
    useMaterial3: true, // Recommended for modern Flutter apps
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // Further customizations for dark theme:
    // appBarTheme: AppBarTheme( ... ),
    // cardTheme: CardTheme( ... ),
  );
}
