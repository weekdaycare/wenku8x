import 'package:flutter/material.dart';

final glacierTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2E72E5),
    primaryContainer: Color(0xFF6C9CEC),
    secondary: Color(0xFF83879C),
    background: Color(0xFFEAEEF2),
    onBackground: Color(0xFF07103A),
    surface: Color(0xFFF1F5F8),
    outline: Color(0xFFD7DEE5),
  ),
);

final glacierDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6C9CEC), 
    primaryContainer: Color(0xFF2E72E5), 
    secondary: Color(0xFFB0B7C1), 
    background: Color(0xFF1A1C22),
    onBackground: Color(0xFFE0E0E0),
    surface: Color(0xFF2C2E34),
    onSurface: Color(0xFFE0E0E0),
    outline: Color(0xFF4C4F55),
  ),
);
