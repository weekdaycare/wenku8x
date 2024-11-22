import 'package:flutter/material.dart';

final walnutTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFA57938),
    primaryContainer: Color(0xFFA57938),
    secondary: Color(0xFF818181),
    onSurface: Color(0xFF040403),
    surface: Color(0xFFF6F1DC),
    outline: Color(0xFFE6E0CD),
  ),
);

final walnutDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFA57938),
    primaryContainer: Color(0xFF8C6A2D),
    secondary: Color(0xFFB0B0B0),
    surface: Color(0xFF2A2A2A),
    onSurface: Color(0xFFE0E0E0),
    outline: Color(0xFF444444),
  ),
);
