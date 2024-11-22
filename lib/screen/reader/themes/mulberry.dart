import 'package:flutter/material.dart';

final mulberryTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFF75C2F),
    primaryContainer: Color(0xFFF98C6D),
    secondary: Color(0xFFA1A1A1),
    background: Color(0xFFF4F4EF),
    onBackground: Color(0xFF242424),
    surface: Color(0xFFFFFFFF),
    outline: Color(0xFFEEEEEE),
  ),
);

final mulberryDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFF98C6D),
    primaryContainer: Color(0xFFF75C2F),
    secondary: Color(0xFFB0B0B0),
    background: Color(0xFF1E1E1E),
    onBackground: Color(0xFFE0E0E0),
    surface: Color(0xFF2A2A2A),
    onSurface: Color(0xFFE0E0E0),
    outline: Color(0xFF444444),
  ),
);
