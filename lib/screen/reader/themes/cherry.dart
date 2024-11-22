import 'package:flutter/material.dart';

final cherryTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF889E),
    primaryContainer: Color(0xFFFFABBB),
    secondary: Color(0xFF838D8A),
    onSurface: Color(0xFF3D2A2B),
    surface: Color(0xFFFFF4F6),
    outline: Color(0xFFF9E3E7),
  ),
);

final cherryDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF889E),
    primaryContainer: Color(0xFFFFABBB),
    secondary: Color(0xFFB0C4C4),
    surface: Color(0xFF2A2A2A),
    onSurface: Color(0xFFE0E0E0),
    outline: Color(0xFF4B4B4B),
  ),
);

