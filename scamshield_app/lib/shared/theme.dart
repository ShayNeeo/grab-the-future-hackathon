import 'package:flutter/material.dart';

ThemeData elderlyTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      useMaterial3: true,
    );
