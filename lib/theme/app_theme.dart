import 'package:flutter/material.dart';

const Color navy = Color(0xFF0B1220);
const Color panel = Color(0xFF141F30);
const Color panelLight = Color(0xFF1B2A3D);
const Color teal = Color(0xFF2DD4BF);
const Color muted = Color(0xFF94A3B8);
const Color danger = Color(0xFFFF647C);
const Color warning = Color(0xFFFBBF24);

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        brightness: Brightness.dark,
        surface: panel,
      ),
      fontFamily: 'Roboto',
    );
  }
}
