import 'package:flutter/material.dart';

final springTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF54B88B),
    primaryContainer: Color(0xFF87CDAD),
    secondary: Color(0xFF838D8A),
    onSurface: Color(0xFF081B16),
    surface: Color(0xFFF7FCF3),
    outline: Color(0xFFE3EBDC),
  ),
);

final springDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF87CDAD),
    primaryContainer: Color(0xFF54B88B),
    secondary: Color(0xFFB0B3B1),
    surface: Color(0xFF2A2E2A),
    onSurface: Color(0xFFE0E0E0),
    outline: Color(0xFF444B48),
  ),
);
